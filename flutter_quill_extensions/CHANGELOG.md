# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The [previous `CHANGELOG.md`](https://github.com/singerdmx/flutter-quill/blob/master/doc/OLD_CHANGELOG.md) has been archived.

## [Unreleased]

## [11.0.0] - 2025-02-16

> [!IMPORTANT]
> See the [migration guide from 10.0.0 to 11.0.0](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md) for the full breaking changes and migration. Ensure to read the [breaking behavior](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md#-breaking-behavior) section to avoid unexpected changes.

### Fixed

- Replace the dependency [`universal_html`](https://pub.dev/packages/universal_html) with [`web`](https://pub.dev/packages/web) to avoid WASM compilation issues.

### Removed

- **BREAKING**: The [`super_clipboard`](https://pub.dev/packages/super_clipboard) plugin from [flutter_quill_extensions](https://pub.dev/packages/flutter_quill_extensions).
- **BREAKING**: The deprecated support for loading YouTube videos in `flutter_quill_extensions`.
- The following packages are no longer dependencies of `flutter_quill_extensions`:
  * [http](https://pub.dev/packages/http)
  * [cross_file](https://pub.dev/packages/cross_file)

### Added

- `Insert video` string in `quill_en.arb` to support localization. Currently available **only in English**.

### Changed

- Separate the package version and `CHANGELOG.md` from [flutter_quill](https://pub.dev/packages/flutter_quill).
- Improve pub topics in package metadata.
- Update the minimum supported SDK version to **Flutter 3.0/Dart 3.0** for compatibility, fixing [#2347](https://github.com/singerdmx/flutter-quill/issues/2347).
- Improve dependencies constraints for compatibility.
- **BREAKING**: Update configuration class names to use the suffix `Config` instead of `Configurations`.
- The `QuillSimpleToolbar` base button options now support buttons of `flutter_quill_extensions`.
- Rewrite the image save functionality with support for all platforms [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- Ignore `unreachable_switch_default` warning (introduced in Dart 3.6) [#2416](https://github.com/singerdmx/flutter-quill/pull/2416).
- Address warnings of `unreachable_switch_default` (introduced in Dart 3.6).
- Use `Slider.adaptive` for the image resize slider on Apple platforms for consistency with `CupertinoActionSheet`.
