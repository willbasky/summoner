# Summoner

1.0.7
=====

* [#82](https://github.com/kowainik/summoner/issues/82):
  Add stackage badges
* [#109](https://github.com/kowainik/summoner/issues/109):
  Fix travis cache directories

1.0.6
=====

* Use `relude` instead of `universum`
* [#105](https://github.com/kowainik/summoner/issues/105):
  Add `--ignore-config` option.

1.0.5
=====

* [#100](https://github.com/kowainik/summoner/issues/100):
  Bump up to `ghc-8.4.3`. Add support for `Ghc843` in code
  and make it default.
* Make CI badges in README be shown depending on the chosen options.
* [#99](https://github.com/kowainik/summoner/issues/99):
  UseTravis-specific env variable `TRAVIS_BUILD_DIR` in created travis file.
* [#97](https://github.com/kowainik/summoner/issues/97):
  Add cabal to created travis file.
* [#96](https://github.com/kowainik/summoner/issues/96):
  Add option to choose `cabal`, `stack` or both.

1.0.4
=====
* Bump up `tomland` to version `0.3`.

1.0.3
=====
* [#92](https://github.com/kowainik/summoner/issues/92):
  Remove -fhide-source-paths from generated stack yaml files for
  GHC < 8.2

1.0.2
=====

* [#87](https://github.com/kowainik/summoner/issues/87):
  Fix Travis matrix for not default `ghc` versions.

1.0.1
=====

* [#85](https://github.com/kowainik/summoner/issues/85):
  Remove `base-noprelude` from dependencies.

1.0.0
=====

* __Important:__ Rename `hs-init` to `summoner`. Transform the script into the package.
* [#54](https://github.com/kowainik/summoner/issues/54):
   Rename `on` and `off` commands to `with` and `without`.
* [#48](https://github.com/kowainik/summoner/issues/48):
  - Add ability to write configurations file. Remove `Targets` data type.
    Use `Config` instead for default, file and CLI configurations.
* [#60](https://github.com/kowainik/summoner/issues/60):
  Use custom prelude `universum`.
* [#39](https://github.com/kowainik/summoner/issues/39):
  Add option to use custom prelude in CLI and in `.toml` configuration.
* [#38](https://github.com/kowainik/summoner/issues/38):
  Add option to add default extensions to `.toml` config.
* [#62](https://github.com/kowainik/summoner/issues/62):
  Make some parts of output not only colorful, but also bold. This makes output prettier.
* [#67](https://github.com/kowainik/summoner/issues/67):
  Add `Aswer` data type to handle yes-no CLI questions.
* [#61](https://github.com/kowainik/summoner/issues/61):
  Add CLI `--version` option.
* [#73](https://github.com/kowainik/summoner/issues/73):
  Make custom prelude be table in toml.
* [#74](https://github.com/kowainik/summoner/issues/74):
  Print hierarchy tree for the created project.

# hs-init

0.0.4
=====
* Now works on windows systems as well
* Add powershell install script for Windows


0.0.3
=====

* [#45](https://github.com/vrom911/hs-init/issues/45):
  Support AppVeyor CI for created projects.

0.0.2
=====

* Use metavar for on-off commands.
* Upgrade `lts` to `10.3`, use `ghc 8.2.2` as default value.

0.0.1
=====

* [#36](https://github.com/vrom911/hs-init/issues/36):
  Add option for creating private repositories — `-p | --private`.
