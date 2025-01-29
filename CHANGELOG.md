# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The [previous `CHANGELOG.md`](https://github.com/singerdmx/flutter-quill/blob/master/doc/OLD_CHANGELOG.md) has been archived.

## [Unreleased]

### Added

- Bosnian (bs), Macedonian (mk) and Gujarati (gu) language translations [#2455](https://github.com/singerdmx/flutter-quill/pull/2455).

## [11.0.0-dev.21] - 2025-01-21

### Added

- `enableClipboardPaste` flag in `QuillToolbarClipboardButton` to determine if the button defaults to `null,` which will use `ClipboardMonitor`, which checks every second if the clipboard has content to paste [#2427](https://github.com/singerdmx/flutter-quill/pull/2427).

## [11.0.0-dev.20] - 2025-01-19

### Changed

- **BREAKING**: Change the `options` parameter class type from `QuillToolbarToggleStyleButtonOptions` to `QuillToolbarClipboardButtonOptions` in `QuillToolbarClipboardButton`. To migrate, use `QuillToolbarClipboardButtonOptions` instead of `QuillToolbarToggleStyleButtonOptions` [#2433](https://github.com/singerdmx/flutter-quill/pull/2433). This change was made for the PR [#2427](https://github.com/singerdmx/flutter-quill/pull/2427).
- **BREAKING**: Change the `onTapDown` to accept `TapDownDetails` instead of `TapDragDownDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL259-L261) due to regressions).
- **BREAKING**: Change the `onTapUp` to accept `TapUpDetails` instead of `TapDragUpDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL263-L265) due to regressions).
- **BREAKING**: Revert [`Copy TapAndPanGestureRecognizer from TextField` PR #2128](https://github.com/singerdmx/flutter-quill/pull/2128), restoring editor behavior to match versions before [`10.4.0`](https://pub.dev/packages/flutter_quill/changelog#1040) due to the regressions [#2413](https://github.com/singerdmx/flutter-quill/pull/2413).

### Removed

- **BREAKING**: The magnifier feature due to buggy behavior [#2413](https://github.com/singerdmx/flutter-quill/pull/2413). See [#2406](https://github.com/singerdmx/flutter-quill/issues/2406) for a list of reasons.

## [11.0.0-dev.19] - 2025-01-10

### Added

- Croatian (hr) language translation [#2431](https://github.com/singerdmx/flutter-quill/pull/2431).

## [11.0.0-dev.18] - 2025-01-06

### Changed

- **BREAKING**: Clipboard action buttons in `QuillSimpleToolbar` are now disabled by default. To enable them, set `showClipboardCut`, `showClipboardCopy`, and `showClipboardPaste` to `true` in `QuillSimpleToolbarConfig`.

## [11.0.0-dev.17] - 2024-12-19

### Fixed

- The color picker dialog's hex field does not use the correct value of the selected text in the editor [#2415](https://github.com/singerdmx/flutter-quill/pull/2415).

## [11.0.0-dev.16] - 2024-12-13

### Changed

- Address warnings of `unreachable_switch_default` (introduced in Dart 3.6).

## [11.0.0-dev.15] - 2024-12-13

### Added

- New localization strings for the image save functionality [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).

### Changed

- Rewrite the image save functionality for [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions) [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- Migrate [quill_native_bridge](https://pub.dev/packages/quill_native_bridge) to `11.0.0` [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- Avoid using deprecated APIs in Flutter 3.27.0 [#2416](https://github.com/singerdmx/flutter-quill/pull/2416):
    - Migrate from `withOpacity` to `withValues` according to [Color wide gamut - Opacity migration](https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework#opacity).
    - Avoid using the deprecated `Color.value` getter.
- Ignore `unreachable_switch_default` warning (introduced in Dart 3.6) [#2416](https://github.com/singerdmx/flutter-quill/pull/2416).
- Update `intl` dependency to support versions `0.19.0` and `0.20.0` [#2416](https://github.com/singerdmx/flutter-quill/pull/2416).

### Fixed

- Avoid using [`url_launcher_string.dart`](https://pub.dev/documentation/url_launcher/latest/url_launcher_string/url_launcher_string-library.html) which is [**strongly discouraged**](https://pub.dev/packages/url_launcher#urls-not-handled-by-uri) [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).

## [11.0.0-dev.14] - 2024-11-24

### Changed

- Improve pub topics in package metadata.
- Update the minimum required version of the dependency [quill_native_bridge](https://pub.dev/packages/quill_native_bridge) from `10.7.9` to `10.7.11`.

## [11.0.0-dev.13] - 2024-11-17

### Changed

- Improve khmer localization [#2372](https://github.com/singerdmx/flutter-quill/pull/2372).

### Fixed

- Clipboard images pasting as plain text on **Android** [#2384](https://github.com/singerdmx/flutter-quill/pull/2384).

## [11.0.0-dev.12] - 2024-11-11

### Changed

- Mark `shouldNotifyListeners` as experimental in `QuillController.replaceText()`.
- Mark the method `QuillController.clipboardSelection()` as experimental.

## [11.0.0-dev.11] - 2024-11-11

### Added

- `onKeyPressed` in `QuillEditorConfig` to customize key press handling in the editor [#2368](https://github.com/singerdmx/flutter-quill/pull/2368).

### Changed

- Improve `README.md`.

## [11.0.0-dev.10] - 2024-11-10

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

[unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.21...HEAD
[11.0.0-dev.21]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.20...v11.0.0-dev.21
[11.0.0-dev.20]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.19...v11.0.0-dev.20
[11.0.0-dev.19]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.18...v11.0.0-dev.19
[11.0.0-dev.18]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.17...v11.0.0-dev.18
[11.0.0-dev.17]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.16...v11.0.0-dev.17
[11.0.0-dev.16]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.15...v11.0.0-dev.16
[11.0.0-dev.15]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.14...v11.0.0-dev.15
[11.0.0-dev.14]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.13...v11.0.0-dev.14
[11.0.0-dev.13]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.12...v11.0.0-dev.13
[11.0.0-dev.12]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.11...v11.0.0-dev.12
[11.0.0-dev.11]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.10...v11.0.0-dev.11
[11.0.0-dev.10]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.6...v11.0.0-dev.10
[11.0.0-dev.6]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.5...v11.0.0-dev.6
[11.0.0-dev.5]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.4...v11.0.0-dev.5
[11.0.0-dev.4]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.3...v11.0.0-dev.4
[11.0.0-dev.3]: https://github.com/singerdmx/flutter-quill/compare/v11.0.0-dev.2...v11.0.0-dev.3
[11.0.0-dev.2]: https://github.com/singerdmx/flutter-quill/compare/v10.8.5...v11.0.0-dev.2
[10.8.5]: https://github.com/singerdmx/flutter-quill/compare/v9.4.0...v10.8.5
[9.4.0]: https://github.com/singerdmx/flutter-quill/releases/tag/v9.4.0
