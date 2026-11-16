"""Generate <plugin>.wz/docs/api.md from the plugin's LuaLS annotations.

Usage, from the repository root:
  python3 -I .github/scripts/apidoc.py           write docs/api.md
  python3 -I .github/scripts/apidoc.py --check   exit 1 if docs/api.md is stale

The plugin name comes from plugin/<name>/api.lua. The script runs
`lua-language-server --doc` on plugin/ and renders its doc.json.
The class that plugin/<plugin>/api.lua declares is the root. Each field of the
root that is itself a documented class becomes a module section. Every other
documented class or alias that a signature names is listed under Types.

Each function gets the same shape: a heading with its name, a `lua` block with
the full signature, the description, then Parameters and Returns lists.
"""

import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

TYPE_NAME = re.compile(r"[A-Za-z_][\w.]*")


def run_luals(plugin_dir: Path) -> list:
    out = Path(tempfile.mkdtemp(prefix="apidoc-"))
    try:
        subprocess.run(
            ["lua-language-server", f"--doc={plugin_dir}", f"--doc_out_path={out}", f"--logpath={out}/log"],
            check=True,
            capture_output=True,
        )
        return json.loads((out / "doc.json").read_text(encoding="utf-8"))
    finally:
        shutil.rmtree(out, ignore_errors=True)


def defined_in(entry: dict, prefix: str) -> bool:
    """True when LuaLS saw this type declared in a file of the plugin."""
    return any(d.get("file", "").startswith(prefix) for d in entry.get("defines", []))


def source_order(field: dict) -> tuple:
    return (field.get("file", ""), field.get("start", [0, 0]))


def optional(view: str) -> tuple[bool, str]:
    """Split `T|nil` or `T?` into (True, T)."""
    view = (view or "any").strip()
    if view.endswith("?"):
        view = view[:-1].strip()
        if view.startswith("(") and view.endswith(")"):
            view = view[1:-1]
        return True, re.sub(r"\|nil$", "", view)
    if view.endswith("|nil"):
        return True, view[: -len("|nil")]
    return False, view


# (expansion, alias name) pairs, longest expansion first. Set by Doc.__init__.
ALIASES: list[tuple[str, str]] = []


def generic(view: str) -> str:
    """Prepare a type for display.

    LuaLS writes generics as `<T>`; the signature reads better as `T`. LuaLS
    also prints an alias by name in one run and expanded in another, so every
    expansion goes back to its alias name. That keeps the output stable."""
    for expansion, name in ALIASES:
        view = view.replace(expansion, name)
    return re.sub(r"<(\w+)(?::\w+)?>", r"\1", view)


def oneline(text: str) -> str:
    return " ".join((text or "").split())


def item(name: str, view: str, desc: str, opt: bool = False) -> str:
    """One list entry: `name` (`type`, optional): description."""
    kind = f"`{generic(view)}`" + (", optional" if opt else "")
    desc = oneline(desc)
    word = desc.split(" ", 1)[0] if desc else ""
    if word[:1].isupper() and word[1:].islower():  # "Sorted" -> "sorted", keep "WezTerm", "URL"
        desc = desc[0].lower() + desc[1:]
    return f"- `{name}` ({kind})" + (f": {desc}" if desc else "")


def qualify(desc: str, module: str) -> str:
    """Examples call functions through the module's local `M`. Show the public name."""
    return re.sub(
        r"```lua\n.*?```",
        lambda m: re.sub(r"\bM([.:])", module + r"\1", m.group(0)),
        desc,
        flags=re.S,
    )


def anchor(heading: str) -> str:
    """GitHub's heading anchor: lowercase, punctuation dropped, spaces to hyphens."""
    return re.sub(r"[^\w\- ]", "", heading.lower()).replace(" ", "-")


assert anchor("warp.wz API reference") == "warpwz-api-reference"
assert anchor("warp.list") == "warplist"


def public(field: dict) -> bool:
    return field.get("visible", "public") == "public" and not field["name"].startswith("_")


def is_function(field: dict) -> bool:
    return field.get("extends", {}).get("type") == "function"


class Doc:
    def __init__(self, repo: Path, name: str):
        self.name = name
        self.plugin_dir = repo / "plugin"
        self.types = {e["name"]: e for e in run_luals(self.plugin_dir)}
        ALIASES[:] = sorted(
            {
                (d["view"], e["name"])
                for e in self.types.values()
                for d in e.get("defines", [])
                if d.get("type") == "doc.alias" and re.search(r"[|(]", d.get("view", ""))
            },
            key=lambda pair: -len(pair[0]),
        )
        self.prefix = f"{name}/"
        self.sources: dict[str, str] = {}
        self.root = self.module_class(f"{name}.api")
        if not self.root:  # api.lua can be `return require "<name>.core"`
            m = re.search(r'^return\s+require\s*\(?\s*["\']([\w.]+)["\']', self.source(f"{name}/api.lua"), re.M)
            self.root = m and self.module_class(m.group(1))
        if not self.root:
            sys.exit(f"{name}: plugin/{name}/api.lua declares no ---@class and returns no module with one")
        self.unresolved: list[str] = []
        self.title = f"{name}.wz API reference"
        # Under every ## heading: a link back to the title and its module list.
        self.back = [f"[Back to top](#{anchor(self.title)})", ""]
        self.referenced: set[str] = set()

    def source(self, rel: str) -> str:
        if rel not in self.sources:
            path = self.plugin_dir / rel
            self.sources[rel] = path.read_text(encoding="utf-8") if path.exists() else ""
        return self.sources[rel]

    def module_class(self, module: str) -> dict | None:
        """The ---@class declared in the file that `require(module)` loads."""
        base = module.replace(".", "/")
        for rel in (f"{base}.lua", f"{base}/init.lua"):
            if self.source(rel):
                return self.returned_class(rel)
        return None

    def returned_class(self, rel: str) -> dict | None:
        """The ---@class on the table a file returns: the annotation directly above
        `local M = ...` (for `return M`) or above the final `return ...` itself."""
        lines = self.source(rel).split("\n")
        ret = next((i for i in range(len(lines) - 1, -1, -1) if lines[i].startswith("return")), None)
        if ret is None:
            return None
        m = re.match(r"return\s+(\w+)\s*$", lines[ret])
        target = ret
        if m:
            decl = re.compile(rf"^local\s+{m.group(1)}\s*=")
            target = next((i for i, line in enumerate(lines) if decl.match(line)), ret)
        classes = {
            d.get("start", [0, 0])[0]: e
            for e in self.types.values()
            for d in e.get("defines", [])
            if d.get("file") == rel and d.get("type") == "doc.class"
        }
        i = target - 1
        while i >= 0 and lines[i].startswith("---"):
            if i in classes:
                return classes[i]
            i -= 1
        return None

    def expression(self, field: dict) -> str:
        """Source text of the value assigned to a field, such as `core.add`."""
        ext = field.get("extends", {})
        (l1, c1), (l2, c2) = ext.get("start", [0, 0]), ext.get("finish", [0, 0])
        lines = self.source(field.get("file", "")).split("\n")
        return lines[l1][c1:c2] if l1 == l2 and l1 < len(lines) else ""

    def requires(self, rel: str) -> dict[str, str]:
        found = re.findall(r'^local\s+(\w+)\s*=\s*require\s*\(?\s*["\']([\w.]+)["\']', self.source(rel), re.M)
        return dict(found)

    def required_class(self, field: dict) -> dict | None:
        """`M.assert = assert` where `local assert = require "warden.assert"`."""
        if field.get("extends", {}).get("type") != "getlocal":
            return None
        module = self.requires(field.get("file", "")).get(self.expression(field))
        return module and self.module_class(module)

    def resolve(self, field: dict, depth: int = 0) -> dict:
        """Follow `M.add = core.add` to the documented field it re-exports."""
        if depth > 5 or field.get("extends", {}).get("type") != "getfield":
            return field
        m = re.fullmatch(r"(\w+)\.(\w+)", self.expression(field))
        module = m and self.requires(field.get("file", "")).get(m.group(1))
        cls = module and self.module_class(module)
        target = cls and next((f for f in cls.get("fields") or [] if f["name"] == m.group(2)), None)
        if not target:
            return field
        return dict(self.resolve(target, depth + 1), name=field["name"])

    def class_desc(self, entry: dict) -> str:
        for d in entry.get("defines", []):
            # Only the ---@class line: a typed variable's comment is not the class's text.
            if d.get("type") == "doc.class" and d.get("rawdesc"):
                return d["rawdesc"].strip()
        return ""

    def note(self, view: str) -> None:
        self.referenced.update(TYPE_NAME.findall(generic(view or "")))

    def function(self, qualified: str, field: dict) -> list[str]:
        ext = field["extends"]
        raw = ext.get("args", [])
        method = any(a.get("name") == "self" for a in raw)
        args = [dict(a, name=a.get("name") or "...") for a in raw if a.get("name") != "self"]
        returns = ext.get("returns") or []
        if method:
            owner, fn = qualified.rsplit(".", 1)
            qualified = f"{owner}:{fn}"

        params = []
        for a in args:
            opt, view = optional(a.get("view"))
            self.note(view)
            params.append((a["name"], view, a.get("rawdesc", ""), opt))
        sig_args = ", ".join(f"{n}{'?' if o else ''}: {generic(v)}" for n, v, _, o in params)
        sig = f"{qualified}({sig_args})"
        if returns:
            rets = ", ".join(
                (f"{r['name']}: " if r.get("name") else "") + generic(r.get("view", "any")) for r in returns
            )
            sig += f" -> {rets}"

        out = [f"### {qualified}", "", "```lua", sig, "```", ""]
        desc = (ext.get("rawdesc") or field.get("rawdesc") or "").strip()
        if desc:
            out += [qualify(desc, re.split(r"[.:](?=[^.:]*$)", qualified)[0]), ""]
        if params:
            out += ["**Parameters:**", ""]
            out += [item(n, v, d, o) for n, v, d, o in params]
            out.append("")
        if returns:
            out += ["_Returns:_", ""]
            for i, r in enumerate(returns, 1):
                self.note(r.get("view", ""))
                opt, view = optional(r.get("view"))
                out.append(item(r.get("name") or f"#{i}", view, r.get("rawdesc", ""), opt))
            out.append("")
        return out

    def section(self, qualified: str, entry: dict) -> list[str]:
        out = [f"## {qualified}", "", *self.back]
        desc = self.class_desc(entry)
        if desc:
            out += [desc, ""]
        fields = sorted((f for f in entry.get("fields") or [] if public(f)), key=source_order)
        fields = [self.resolve(f) for f in fields]
        typed = [f for f in fields if not is_function(f) and self.value_view(f).startswith("fun(")]
        values = [f for f in fields if not is_function(f) and f not in typed]
        for f in values:
            alias = re.match(r"\w+", self.expression(f) or "")
            module = alias and self.requires(f.get("file", "")).get(alias.group(0)) or ""
            if module.startswith(f"{self.name}."):  # re-export of an own module without ---@class
                self.unresolved.append(f"{qualified}.{f['name']}")
        if values:
            out += ["Values:", ""]
            for f in values:
                view = f.get("extends", {}).get("view") or "unknown"
                if view == "unknown":  # assigned from a local: use the field's own ---@type
                    view = f.get("view") or "unknown"
                self.note(view)
                out.append(item(f"{qualified}.{f['name']}", view, f.get("rawdesc", "")))
            out.append("")
        for f in fields:
            if is_function(f):
                out += self.function(f"{qualified}.{f['name']}", f)
            elif f in typed:
                out += self.typed_function(f"{qualified}.{f['name']}", f)
        return out

    def value_view(self, field: dict) -> str:
        view = field.get("extends", {}).get("view") or "unknown"
        return field.get("view") or view if view == "unknown" else view

    def typed_function(self, qualified: str, field: dict) -> list[str]:
        """A field declared as `---@field name fun(a: T): R`: signature and description only."""
        view = self.value_view(field)
        self.note(view)
        depth, close = 0, len(view)
        for i, ch in enumerate(view):
            depth += ch == "("
            depth -= ch == ")"
            if ch == ")" and depth == 0:
                close = i
                break
        params, rest = view[4:close], view[close + 1 :].strip()
        if re.match(r"self\s*:", params):  # method: drop self, call with `:`
            params = re.sub(r"^self\s*:\s*[^,]+,?\s*", "", params)
            owner, fn = qualified.rsplit(".", 1)
            qualified = f"{owner}:{fn}"
        sig = f"{qualified}({params})" + (f" -> {rest[1:].strip()}" if rest.startswith(":") else "")
        out = [f"### {qualified}", "", "```lua", generic(sig), "```", ""]
        desc = (field.get("rawdesc") or "").strip()
        return out + ([desc, ""] if desc else [])

    def type_entry(self, entry: dict) -> list[str]:
        out = [f"### {entry['name']}", ""]
        alias = [d for d in entry.get("defines", []) if d.get("type") == "doc.alias"]
        if alias:
            return out + ["```lua", f"---@alias {entry['name']} {alias[0].get('view', '')}", "```", ""]
        desc = self.class_desc(entry)
        if desc:
            out += [desc, ""]
        fields = sorted((f for f in entry.get("fields") or [] if public(f)), key=source_order)
        if fields:
            out += ["Fields:", ""]
            for f in fields:
                view = f.get("extends", {}).get("view") or f.get("view") or "any"
                # A trailing `|nil` in a fun() type belongs to its return value.
                opt, view = (False, view) if view.startswith("fun(") else optional(view)
                out.append(item(f["name"], view, f.get("rawdesc", ""), opt))
            out.append("")
        return out

    def render(self) -> str:
        n = self.name
        modules, own_fields = [], []
        for f in sorted(self.root.get("fields") or [], key=source_order):
            target = self.types.get(f.get("extends", {}).get("view") or "") or self.required_class(f)
            if public(f) and target and defined_in(target, self.prefix) and target is not self.root:
                modules.append((f"{n}.{f['name']}", target))
            else:
                own_fields.append(f)
        own = dict(self.root, fields=own_fields)
        has_own = any(public(f) for f in own_fields)

        body = self.section(n, own) if has_own else []
        for qualified, entry in modules:
            body += self.section(qualified, entry)

        # Classes the API returns or takes. A class with methods (a builder, a
        # logger, a store) gets a full section. Data-only classes go under Types.
        shown = {self.root["name"], *(e["name"] for _, e in modules)}
        objects, types, seen = [], [], set()
        while True:
            pending = sorted(self.referenced - seen - shown)
            if not pending:
                break
            for t in pending:
                seen.add(t)
                entry = self.types.get(t)
                if not entry or not defined_in(entry, self.prefix):
                    continue
                fields = [self.resolve(f) for f in entry.get("fields") or [] if public(f)]
                if any(is_function(f) or self.value_view(f).startswith("fun(") for f in fields):
                    objects.append(entry)
                    body += self.section(t, entry)
                else:
                    types.append(entry)
                    for f in fields:
                        self.note(f.get("extends", {}).get("view") or f.get("view", ""))
        types.sort(key=lambda e: e["name"])

        head = [
            f"# {self.title}",
            "",
            "<!-- Generated by community/apidoc.py from the LuaLS annotations in plugin/. Do not edit. -->",
            "",
            "Each entry shows the full signature, then its parameters and return values.",
            "A `?` after a parameter name marks it optional. To fix an entry, edit the",
            "source annotations and generate this file again.",
            "",
        ]
        toc = ([f"- [{n}](#{n})"] if has_own else []) + [
            f"- [{q}](#{anchor(q)})" for q in [q for q, _ in modules] + [e["name"] for e in objects]
        ]
        if types:
            toc.append("- [Types](#types)")
        tail = ["## Types", "", *self.back] if types else []
        for e in types:
            tail += self.type_entry(e)
        for name in self.unresolved:
            print(f"warning: {name} is re-exported from an undocumented module", file=sys.stderr)
        text = "\n".join(head + toc + [""] + body + tail).rstrip() + "\n"
        return self.relink(text)

    def relink(self, text: str) -> str:
        """Turn the absolute file:// links LuaLS writes into repo-relative ones."""
        repo = self.plugin_dir.parent.as_uri()

        def fix(m: re.Match) -> str:
            url, line = m.group(1), m.group(2)
            if not url.startswith(repo + "/"):
                sys.exit(f"{self.name}: link outside the repository: {url}")
            rel = "../" + url[len(repo) + 1 :]
            return f"]({rel}#L{line})" if line else f"]({rel})"

        text = re.sub(r"\]\((file://[^)#]+)(?:#(\d+))?\)", fix, text)
        if "file://" in text:
            sys.exit(f"{self.name}: unhandled file:// link left in output")
        return text


# Same version as the files workflow, so the output matches what CI checks.
PRETTIER = "prettier@3.9.10"


def prettier(text: str) -> str:
    """Format like the files workflow does, so the committed file is the generated one."""
    done = subprocess.run(
        ["npx", "--yes", PRETTIER, "--stdin-filepath", "docs/api.md"],
        input=text,
        capture_output=True,
        text=True,
        check=True,
    )
    return done.stdout


def main() -> None:
    check = sys.argv[1:] == ["--check"]
    if sys.argv[1:] not in ([], ["--check"]):
        sys.exit(__doc__)
    repo = Path.cwd()
    apis = sorted(repo.glob("plugin/*/api.lua"))
    if len(apis) != 1:
        sys.exit("run from the repository root: need exactly one plugin/<name>/api.lua")
    text = prettier(Doc(repo, apis[0].parent.name).render())
    target = repo / "docs" / "api.md"
    if check:
        if not target.exists() or target.read_text(encoding="utf-8") != text:
            sys.exit("docs/api.md is out of date. Run: python3 -I .github/scripts/apidoc.py")
        print("docs/api.md is up to date")
        return
    target.parent.mkdir(exist_ok=True)
    target.write_text(text, encoding="utf-8")
    print(target.relative_to(repo))


if __name__ == "__main__":
    main()
