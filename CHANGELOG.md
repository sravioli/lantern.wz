# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [1.3.0](https://github.com/sravioli/lantern.wz/compare/17f727ef28c2127df0c6cb4272a5efb6cc596ee1..1.3.0) - 2026-11-16
#### Features
- (**config**) validate options with warden - ([17f727e](https://github.com/sravioli/lantern.wz/commit/17f727ef28c2127df0c6cb4272a5efb6cc596ee1)) - sravioli
#### Bug Fixes
- (**color**) color the fancy tab bar on scheme switch - ([697d8c7](https://github.com/sravioli/lantern.wz/commit/697d8c72e1f94a459369068780673ebd0f4f0217)) - sravioli
#### Documentation
- (**contributing**) document the signed-commit requirement - ([c97c729](https://github.com/sravioli/lantern.wz/commit/c97c7292fcd4cb7f19fd92f290e28772ca911e8c)) - sravioli
- (**contributing**) unify guides and templates - ([7315629](https://github.com/sravioli/lantern.wz/commit/731562934fe31891665867f6baca55fe2f55a9f0)) - sravioli
- (**readme**) unify badge style and add release badge - ([40b806b](https://github.com/sravioli/lantern.wz/commit/40b806b7b98e81e984351cf6f4c04e683f83811f)) - sravioli
- (**readme**) document option validation and checks - ([6079562](https://github.com/sravioli/lantern.wz/commit/60795624c7d588c15dfdd08f7ce7204a45305ffd)) - sravioli
- document working-tree local checkout setup - ([98c0067](https://github.com/sravioli/lantern.wz/commit/98c0067945c06840e830ff2449666d94c0e18e48)) - sravioli
#### Tests
- (**config**) cover option validation - ([9051545](https://github.com/sravioli/lantern.wz/commit/90515459c0f3895098c5507e9d0f11f28450a9c1)) - sravioli
#### Continuous Integration
- (**lint**) declare busted finally for selene - ([4e4ae7a](https://github.com/sravioli/lantern.wz/commit/4e4ae7a7d71bf9a498282860b79872325fe1374e)) - sravioli
- (**tests**) clone warden.wz for specs - ([54d2866](https://github.com/sravioli/lantern.wz/commit/54d2866ec0654ac1e6788c39f81f8dc13d9e339a)) - sravioli
- build the API reference from a majority of three LuaLS runs - ([8bffdf4](https://github.com/sravioli/lantern.wz/commit/8bffdf4c63907c363c9319b55e7c08eb5af0be2c)) - sravioli
- update the actions to the versions Dependabot proposed - ([ad8b757](https://github.com/sravioli/lantern.wz/commit/ad8b75726e0ffbb9be2c6f357190a917e10a2092)) - sravioli
- pin StyLua to 2.6.0 - ([4b4b6e7](https://github.com/sravioli/lantern.wz/commit/4b4b6e71124e9dee4c6531906fc39f3621d60da2)) - sravioli
- fix the flaky API check and the EditorConfig rate limit - ([1bf6662](https://github.com/sravioli/lantern.wz/commit/1bf666261712612043759d6fafc66f84a12cd2b7)) - sravioli

- - -

## [1.2.1](https://github.com/sravioli/lantern.wz/compare/4e77f4a7a5f9adfd03c2d69c53fe7d0ee68d9542..1.2.1) - 2026-11-15
#### Bug Fixes
- (**core**) read cached flame specs as plain tables - ([4571510](https://github.com/sravioli/lantern.wz/commit/457151025dcae6cc0b54a5e1072bee797804cd97)) - sravioli
- (**state**) keep cleared state after migration - ([13d77c8](https://github.com/sravioli/lantern.wz/commit/13d77c87eb9d3d15c02b22638ac613cc59867436)) - sravioli
- (**tab-bar-style**) keep new tab button styles - ([4e77f4a](https://github.com/sravioli/lantern.wz/commit/4e77f4a7a5f9adfd03c2d69c53fe7d0ee68d9542)) - sravioli
#### Performance Improvements
- (**bootstrap**) keep plugin list across reloads - ([026288e](https://github.com/sravioli/lantern.wz/commit/026288e1aac0967cada36888c7921a9691d383be)) - sravioli
- (**startup**) defer GPU and cache plugin scans - ([ac3fcfd](https://github.com/sravioli/lantern.wz/commit/ac3fcfd9eadec9208ce978eeb71c9ec1b6ba6125)) - sravioli
#### Documentation
- (**readme**) update plugin READMEs - ([4d88b91](https://github.com/sravioli/lantern.wz/commit/4d88b910cc1900761f0ef8bc9cc940a883ae4437)) - sravioli
#### Tests
- cover legacy re-import and flame cache - ([656c51f](https://github.com/sravioli/lantern.wz/commit/656c51fe1a4fecb8f54ec90649ac13c51eb47f6a)) - sravioli

- - -

## [1.2.0](https://github.com/sravioli/lantern.wz/compare/7351d18cd726aa1792306cf10eae80f92c0c27f1..1.2.0) - 2026-05-14
#### Features
- (**color**) add tab button formatter hook - ([354a3d3](https://github.com/sravioli/lantern.wz/commit/354a3d3a4810f479726347aa192ede9f3ceb2834)) - sravioli
#### Bug Fixes
- (**state**) normalize restored entries - ([b6f4cec](https://github.com/sravioli/lantern.wz/commit/b6f4cec44c2dddad5269d02aa77d186edd721635)) - sravioli
- (**state**) resolve default paths without warp - ([beec56b](https://github.com/sravioli/lantern.wz/commit/beec56ba4f03f39b33dadf4515a65cd20591143e)) - sravioli
- (**state**) reload persisted choices on rekindle - ([82a607e](https://github.com/sravioli/lantern.wz/commit/82a607e8e6af6cd4ca737b7d576d3f031e9e2aa5)) - sravioli
#### Documentation
- (**github**) add pull request templates - ([16f2c12](https://github.com/sravioli/lantern.wz/commit/16f2c12056ae55ba79e02076c5ed26d05074e1ef)) - sravioli
- (**github**) polish issue templates - ([2ceae49](https://github.com/sravioli/lantern.wz/commit/2ceae4967f15f29dfc82cb9e03f4b35d3cc9de24)) - sravioli
- (**lua**) polish comment wording - ([2ce160b](https://github.com/sravioli/lantern.wz/commit/2ce160b7b87a4f8bb411170681a76ea5b4d4d2ef)) - sravioli
- (**readme**) align documentation with implementation - ([3c416e6](https://github.com/sravioli/lantern.wz/commit/3c416e6025873236a119ad4a0c7a4a7414c71a01)) - sravioli
- (**readme**) restore Awesome WezTerm badge - ([d7ef30b](https://github.com/sravioli/lantern.wz/commit/d7ef30b29934719e1f81b195d14926f5d5df4fd9)) - sravioli
- (**readme**) hide pending upstream claims - ([36356e7](https://github.com/sravioli/lantern.wz/commit/36356e7267980b9eb8de5eb52e7994aaeded9fd9)) - sravioli
- (**readme**) improve readme consistency - ([6ea9136](https://github.com/sravioli/lantern.wz/commit/6ea9136f348a45f9f152da7cba7bd9d10031fb80)) - sravioli
- (**readme**) improve prose clarity - ([7351d18](https://github.com/sravioli/lantern.wz/commit/7351d18cd726aa1792306cf10eae80f92c0c27f1)) - sravioli
#### Refactoring
- (**lantern**) reuse warp helpers - ([32a4abf](https://github.com/sravioli/lantern.wz/commit/32a4abf2e19f5179d6081ece8d3b036d4364559f)) - sravioli
- (**state**) use warp path helpers - ([64ee123](https://github.com/sravioli/lantern.wz/commit/64ee123b15d510204ed4a1b4e40e3ecd7e2049cb)) - sravioli

- - -

## [1.1.0](https://github.com/sravioli/lantern.wz/compare/cb4cadf162646e5c70338ccdded7d2da8356ff43..1.1.0) - 2026-05-08
#### Features
- (**format**) use ribbon for formatted output - ([cb4cadf](https://github.com/sravioli/lantern.wz/commit/cb4cadf162646e5c70338ccdded7d2da8356ff43)) - sravioli
#### Documentation
- (**readme**) document ribbon dependency - ([a00a3c8](https://github.com/sravioli/lantern.wz/commit/a00a3c8bd6030541e6dfb089abfea51818c345cf)) - sravioli

- - -

## [1.0.0](https://github.com/sravioli/lantern.wz/compare/01267f41055872719889b0731b252e62b56722b0..1.0.0) - 2026-05-08
#### Features
- (**flames**) add appearance wicks - ([c2220e9](https://github.com/sravioli/lantern.wz/commit/c2220e9da01953116fa015462aec41ba9f4d5e3d)) - sravioli
- (**flames**) cache directory discovery - ([2eba47c](https://github.com/sravioli/lantern.wz/commit/2eba47cd7bbd8dfcd78b744eaedde0636118ab9b)) - sravioli
- (**gpu**) expose best adapter helper - ([3c330e8](https://github.com/sravioli/lantern.wz/commit/3c330e813cbc65a51badb9473ec504643a1dc4a1)) - sravioli
- (**lantern**) add wick and flame picker engine - ([e71b69d](https://github.com/sravioli/lantern.wz/commit/e71b69d07196548078e875fbae2bac3922e1c815)) - sravioli
#### Bug Fixes
- (**core**) preserve explicit false wick options - ([fcacd59](https://github.com/sravioli/lantern.wz/commit/fcacd5995998c5bfd494e71719571cae1513acbf)) - sravioli
- (**flames**) defer built-in directory scans - ([c03b70f](https://github.com/sravioli/lantern.wz/commit/c03b70f62acc5b21916ce51d62069a06a2d43434)) - sravioli
- (**flames**) scan directories before light events - ([8cbe72f](https://github.com/sravioli/lantern.wz/commit/8cbe72f180e8c88f4b141ed237c97601ae1309a5)) - sravioli
- (**flames**) fallback to glob discovery - ([2103edf](https://github.com/sravioli/lantern.wz/commit/2103edf045ef347e98a65c62fca99900b3e96f2f)) - sravioli
- (**flames**) refresh empty discovery cache - ([ceaa2c3](https://github.com/sravioli/lantern.wz/commit/ceaa2c38dd85940c38084cf284b44bb8c4be91e8)) - sravioli
- (**state**) clear unrestorable wick entries - ([8f652fd](https://github.com/sravioli/lantern.wz/commit/8f652fd7554fbad72604a193c7b2a27411aac90b)) - sravioli
- (**ui**) clarify fuzzy selector prompt - ([cc159e4](https://github.com/sravioli/lantern.wz/commit/cc159e410975a0d3067fb7e1d6745557be466fb6)) - sravioli
#### Documentation
- (**readme**) improve readme clarity - ([86eb231](https://github.com/sravioli/lantern.wz/commit/86eb231743ecc0197e28748ab023e753e5fc5a22)) - sravioli
- (**readme**) document appearance wicks - ([5b322d5](https://github.com/sravioli/lantern.wz/commit/5b322d5b1314eac778e9d0703b491f2e618c7f9d)) - sravioli
- (**readme**) unify project documentation - ([ff6594f](https://github.com/sravioli/lantern.wz/commit/ff6594f838a518445074c0740ebd11f303fd78af)) - sravioli
- (**readme**) document lantern usage - ([11a8ce1](https://github.com/sravioli/lantern.wz/commit/11a8ce1b82cf2859e1a304c59aa89270a3da0cf2)) - sravioli
#### Tests
- (**usage**) cover selector workflows - ([3a388e4](https://github.com/sravioli/lantern.wz/commit/3a388e4af9d4d3e0b716e3b35898bce8785c2c05)) - sravioli
#### Continuous Integration
- add lint, release and test workflows - ([db0a2d9](https://github.com/sravioli/lantern.wz/commit/db0a2d9df5f3ae48260b47107c9ab7407a0655f0)) - sravioli
#### Refactoring
- (**deps**) use shared wezterm plugins - ([11493ae](https://github.com/sravioli/lantern.wz/commit/11493ae0a13e63b454585c0a0f6dcf5049d18693)) - sravioli
- (**gpu**) remove legacy pick alias - ([6ab2f06](https://github.com/sravioli/lantern.wz/commit/6ab2f06462172648f3d30c92a9f946bbd29d5182)) - sravioli

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).