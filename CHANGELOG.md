# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The [previous `CHANGELOG.md`](https://github.com/singerdmx/flutter-quill/blob/master/doc/OLD_CHANGELOG.md) has been archived.

## [Unreleased]

## [11.0.0-dev.9] - 2024-11-10

### Changed

- **[ci]** Improve the publishing workflow.

## [11.0.0-dev.6] - 2024-11-09

> [!IMPORTANT]
> See the [migration guide from 10.0.0 to 11.0.0](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md) for the full breaking changes and migration. Ensure to read the [breaking behavior](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md#-breaking-behavior) section to avoid unexpected changes.

### Added

- `QuillClipboardConfig` class with customizable clipboard paste handling callbacks, partial fix to [#2350](https://github.com/singerdmx/flutter-quill/issues/2350).
- The option to enable/disable rich text paste (from other apps) in `QuillClipboardConfig`.
- `Insert video` string in `quill_en.arb` to support localization for `flutter_quill_extensions`. Currently available **only in English**.

### Fixed

- **[iOS]** Localize the Cupertino link menu actions.
- Export `QuillToolbarSelectLineHeightStyleDropdownButtonOptions`, fixing [#2333](https://github.com/singerdmx/flutter-quill/issues/2333).

### Changed

- Update the minimum supported SDK version to **Flutter 3.0/Dart 3.0** for compatibility, fixing [#2347](https://github.com/singerdmx/flutter-quill/issues/2347).
- Improve dependencies constraints for compatibility.
- Improve `README.md`.
- [Always call `setState()` in `_markNeedsBuild()` in `QuillRawEditorState`](https://github.com/singerdmx/flutter-quill/pull/2338/commits/a127628214c23bb4a7a3b0cdc644fefb21eee738) (**revert to the old behavior**).
- **BREAKING**: Update configuration class names to use the suffix `Config` instead of `Configurations`.
- **BREAKING**: Refactor **embed block interface** for both the `EmbedBuilder.build()` and `EmbedButtonBuilder`.
- [Minor cleanup](https://github.com/singerdmx/flutter-quill/pull/2338/commits/b739b700cbae9c3d4427e4966963d97cebf0a852) to magnifier feature.
- The `QuillSimpleToolbar` base button options now support buttons of `flutter_quill_extensions`.

### Removed

- **BREAKING**: The quill shared configuration class.
- The dependency [equatable](https://pub.dev/packages/equatable).
- The experimental support for spell checking. See [#2246](https://github.com/singerdmx/flutter-quill/issues/2246).

## [11.0.0-dev.5] - 2024-11-08

### Changed

- The option to enable/disable rich text paste (from other apps) in `QuillClipboardConfig`.
- Improve `README.md`.
- Simplify the `example` app.

## [11.0.0-dev.4] - 2024-11-08

### Changed

- Publish the [`flutter_quill`](https://pub.dev/packages/flutter_quill) package with no changes to test the CI workflow.

## [11.0.0-dev.3] - 2024-11-08

### Added

- `Insert video` string in `quill_en.arb` to support localization for `flutter_quill_extensions`. Currently available **only in English**.

## [11.0.0-dev.2] - 2024-11-08

### Changed

- Restore [base button options](https://github.com/singerdmx/flutter-quill/pull/2338/commits/1f51935f1eaa229f01c4d14398708ab2d3bd05b0), now works without the inherited widgets, and support buttons of `flutter_quill_extensions`.

## [10.8.5] - 2024-10-24

### Fixed

- Allow all correct URLs to be formatted [#2328](https://github.com/singerdmx/flutter-quill/pull/2328).
- **[macOS]** Implement actions for `ExpandSelectionToDocumentBoundaryIntent` and `ExpandSelectionToLineBreakIntent` to use keyboard shortcuts, along with unrelated cleanup [#2279](https://github.com/singerdmx/flutter-quill/pull/2279).

## [9.4.0] - 2024-06-13

### Added

- Korean translations [#1911](https://github.com/singerdmx/flutter-quill/pull/1911).

### Changed

- Rework search bar/dialog for **Material 3** UI with on-the-fly search [#1904](https://github.com/singerdmx/flutter-quill/pull/1904).
- Support for subscript and superscript across all languages.
- Improve pasting of Markdown and HTML file content from the system clipboard [#1915](https://github.com/singerdmx/flutter-quill/pull/1915).

### Removed

- Apple-specific font dependency for subscript and superscript functionality from the example.
- **BREAKING**: The [`super_clipboard`](https://pub.dev/packages/super_clipboard) plugin, To restore legacy behavior for `super_clipboard`, use [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions) package and `FlutterQuillExtensions.useSuperClipboardPlugin()`.

[unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.9...HEAD
[11.0.0-dev.9]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.6...v11.0.0-dev.9
[11.0.0-dev.6]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...v11.0.0-dev.6
[11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5
[11.0.0-dev.4]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.3...v11.0.0-dev.4
[11.0.0-dev.3]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.2...v11.0.0-dev.3
[11.0.0-dev.2]: https://github.com/singerdmx/flutter-quill/compare/v10.8.5...v11.0.0-dev.2
[10.8.5]: https://github.com/singerdmx/flutter-quill/compare/v9.4.0...v10.8.5
[9.4.0]: https://github.com/singerdmx/flutter-quill/releases/tag/v9.4.0
