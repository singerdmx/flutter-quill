# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The [previous `CHANGELOG.md`](https://github.com/singerdmx/flutter-quill/blob/master/doc/OLD_CHANGELOG.md) has been archived.

## [Unreleased]

### Added

- Added localization support for `mn` (Mongolian, Mongolia)

## [11.5.0] - 2025-10-18

### Fixed

- Fixed `View.of(context)` calls throwing when used with the `screenshot` package [#2662](https://github.com/singerdmx/flutter-quill/pull/2662).

### Added

- Add missing Brazilian Portuguese translations

## [11.4.2] - 2025-07-22

### Fixed

- **App crash on desktop platforms** when using Flutter `3.32.0-0.5.pre` and newer.  
  Fixed by passing the required `viewId` for experimental multi-window support [#2579](https://github.com/singerdmx/flutter-quill/pull/2579).

## [11.4.1] - 2025-05-15

### Added

- `copyWith` methods to `HorizontalSpacing`, `VerticalSpacing`, `DefaultTextBlockStyle`, and `DefaultListBlockStyle` for immutable updates of properties [#2550](https://github.com/singerdmx/flutter-quill/pull/2550).
- Finnish (fi) language translation [#2564](https://github.com/singerdmx/flutter-quill/pull/2564).

## [11.4.0] - 2025-04-23

### Added

- Accept `mailto`, `tel`, `sms`, and other link prefixes by default in the insert link toolbar button [#2525](https://github.com/singerdmx/flutter-quill/pull/2525).
- `validateLink` in `QuillToolbarLinkStyleButtonOptions` to allow overriding the link validation [#2525](https://github.com/singerdmx/flutter-quill/pull/2525).

### Fixed

- Improve doc comment of `customLinkPrefixes` in `QuillEditor` [#2525](https://github.com/singerdmx/flutter-quill/pull/2525).

### Changed

- Deprecate `linkRegExp` in favor of the new callback `validateLink` [#2525](https://github.com/singerdmx/flutter-quill/pull/2525).

## [11.3.0] - 2025-04-23

### Fixed

- Can't select text when `readOnly` is true [#2529](https://github.com/singerdmx/flutter-quill/pull/2529).

### Added

- Display magnifier using `RawMagnifier` widget when dragging on iOS/Android [#2529](https://github.com/singerdmx/flutter-quill/pull/2529).

## [11.2.0] - 2025-03-26

### Added

- Cache for `toPlainText` in `Document` class to avoid unnecessary text computing [#2482](https://github.com/singerdmx/flutter-quill/pull/2482).

## [11.1.2] - 2025-03-24

### Fixed

- **[iOS]** `QuillEditor` doesn't respect the system keyboard brightness by default [#2522](https://github.com/singerdmx/flutter-quill/pull/2522).
- Add a default empty list for `characterShortcutEvents` and `spaceShortcutEvents` in `QuillRawEditorConfig` [#2522](https://github.com/singerdmx/flutter-quill/pull/2522).
- Deprecate `QuillEditorState.configurations` in favor of `QuillEditorState.config` [#2522](https://github.com/singerdmx/flutter-quill/pull/2522).

## [11.1.1] - 2025-03-19

### Fixed

 - Explicitly schedule frame on secondary click to ensure context menu is shown on Windows [#2507](https://github.com/singerdmx/flutter-quill/pull/2507).

## [11.1.0] - 2025-03-11

### Fixed

- Remove unnecessary content change listeners in read-only mode to avoid triggering infinite loops of **FocusNode** callbacks [#2488](https://github.com/singerdmx/flutter-quill/pull/2488).
- Remove unicode from `QuillText` element that causes weird caret behavior on empty lines [#2453](https://github.com/singerdmx/flutter-quill/pull/2453).
- Focus and open context menu on right click if unfocused [#2477](https://github.com/singerdmx/flutter-quill/pull/2477).
- Update QuillController `length` extension method deprecation message [#2483](https://github.com/singerdmx/flutter-quill/pull/2483).

### Added

- `Rule` is now part of the public API, so that `Document.setCustomRules` can be used.
- `decoration` property in `DefaultTextBlockStyle` for the `header` attribute to customize headers with borders, background colors, and other styles using `BoxDecoration` [#2429](https://github.com/singerdmx/flutter-quill/pull/2429).

## [11.0.0] - 2025-02-16

> [!IMPORTANT]
> See the [migration guide from 10.0.0 to 11.0.0](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md) for the full breaking changes and migration. Ensure to read the [breaking behavior](https://github.com/singerdmx/flutter-quill/blob/master/doc/migration/10_to_11.md#-breaking-behavior) section to avoid unexpected changes.

### Fixed

- **[iOS]** Localize the Cupertino link menu actions.
- Export `QuillToolbarSelectLineHeightStyleDropdownButtonOptions`, fixing [#2333](https://github.com/singerdmx/flutter-quill/issues/2333).
- Clipboard images pasting as plain text on **Android** [#2384](https://github.com/singerdmx/flutter-quill/pull/2384).
- Avoid using [`url_launcher_string.dart`](https://pub.dev/documentation/url_launcher/latest/url_launcher_string/url_launcher_string-library.html) which is [**strongly discouraged**](https://pub.dev/packages/url_launcher#urls-not-handled-by-uri) [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- The color picker dialog's hex field does not use the correct value of the selected text in the editor [#2415](https://github.com/singerdmx/flutter-quill/pull/2415).

### Added

- New localization strings for the image save functionality [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- `Insert video` string in `quill_en.arb` to support localization for `flutter_quill_extensions`. Currently available **only in English**.
- `QuillClipboardConfig` class with customizable clipboard paste handling callbacks, partial fix to [#2350](https://github.com/singerdmx/flutter-quill/issues/2350).
- The option to enable/disable rich text paste (from other apps) in `QuillClipboardConfig`.
- `Insert video` string in `quill_en.arb` to support localization for `flutter_quill_extensions`. Currently available **only in English**.
- `onKeyPressed` in `QuillEditorConfig` to customize key press handling in the editor [#2368](https://github.com/singerdmx/flutter-quill/pull/2368).
- Croatian (hr) language translation [#2431](https://github.com/singerdmx/flutter-quill/pull/2431).
- `enableClipboardPaste` flag in `QuillToolbarClipboardButton` to determine if the button defaults to `null,` which will use `ClipboardMonitor`, which checks every second if the clipboard has content to paste [#2427](https://github.com/singerdmx/flutter-quill/pull/2427).

### Changed

- Rewrite the image save functionality for [`flutter_quill_extensions`](https://pub.dev/packages/flutter_quill_extensions) [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- Migrate [quill_native_bridge](https://pub.dev/packages/quill_native_bridge) to `11.0.0` [#2403](https://github.com/singerdmx/flutter-quill/pull/2403).
- Avoid using deprecated APIs in Flutter 3.27.0 [#2416](https://github.com/singerdmx/flutter-quill/pull/2416):
    - Migrate from `withOpacity` to `withValues` according to [Color wide gamut - Opacity migration](https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework#opacity).
    - Avoid using the deprecated `Color.value` getter.
- Ignore `unreachable_switch_default` warning (introduced in Dart 3.6) [#2416](https://github.com/singerdmx/flutter-quill/pull/2416).
- Update `intl` dependency to support versions `0.19.0` and `0.20.0` [#2416](https://github.com/singerdmx/flutter-quill/pull/2416).
- Restore [base button options](https://github.com/singerdmx/flutter-quill/pull/2338/commits/1f51935f1eaa229f01c4d14398708ab2d3bd05b0), now works without the inherited widgets, and support buttons of `flutter_quill_extensions`.
- The option to enable/disable rich text paste (from other apps) in `QuillClipboardConfig`.
- Improve `README.md`.
- Simplify the `example` app.
- Update the minimum supported SDK version to **Flutter 3.0/Dart 3.0** for compatibility, fixing [#2347](https://github.com/singerdmx/flutter-quill/issues/2347).
- Improve dependencies constraints for compatibility.
- Improve `README.md`.
- [Always call `setState()` in `_markNeedsBuild()` in `QuillRawEditorState`](https://github.com/singerdmx/flutter-quill/pull/2338/commits/a127628214c23bb4a7a3b0cdc644fefb21eee738) (**revert to the old behavior**).
- **BREAKING**: Update configuration class names to use the suffix `Config` instead of `Configurations`.
- **BREAKING**: Refactor **embed block interface** for both the `EmbedBuilder.build()` and `EmbedButtonBuilder`.
- [Minor cleanup](https://github.com/singerdmx/flutter-quill/pull/2338/commits/b739b700cbae9c3d4427e4966963d97cebf0a852) to magnifier feature.
- The `QuillSimpleToolbar` base button options now support buttons of `flutter_quill_extensions`.
- Mark `shouldNotifyListeners` as experimental in `QuillController.replaceText()`.
- Mark the method `QuillController.clipboardSelection()` as experimental.
- Improve pub topics in package metadata.
- Update the minimum required version of the dependency [quill_native_bridge](https://pub.dev/packages/quill_native_bridge) from `10.7.9` to `10.7.11`.
- Address warnings of `unreachable_switch_default` (introduced in Dart 3.6).
- **BREAKING**: Clipboard action buttons in `QuillSimpleToolbar` are now disabled by default. To enable them, set `showClipboardCut`, `showClipboardCopy`, and `showClipboardPaste` to `true` in `QuillSimpleToolbarConfig`.
- **BREAKING**: Change the `options` parameter class type from `QuillToolbarToggleStyleButtonOptions` to `QuillToolbarClipboardButtonOptions` in `QuillToolbarClipboardButton`. To migrate, use `QuillToolbarClipboardButtonOptions` instead of `QuillToolbarToggleStyleButtonOptions` [#2433](https://github.com/singerdmx/flutter-quill/pull/2433). This change was made for the PR [#2427](https://github.com/singerdmx/flutter-quill/pull/2427).
- **BREAKING**: Change the `onTapDown` to accept `TapDownDetails` instead of `TapDragDownDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL259-L261) due to regressions).
- **BREAKING**: Change the `onTapUp` to accept `TapUpDetails` instead of `TapDragUpDetails` (revert [#2128](https://github.com/singerdmx/flutter-quill/pull/2128/files#diff-49ca9b0fdd0d380a06b34d5aed7674bbfb27fede500831b3e1279615a9edd06dL263-L265) due to regressions).
- **BREAKING**: Revert [`Copy TapAndPanGestureRecognizer from TextField` PR #2128](https://github.com/singerdmx/flutter-quill/pull/2128), restoring editor behavior to match versions before [`10.4.0`](https://pub.dev/packages/flutter_quill/changelog#1040) due to the regressions [#2413](https://github.com/singerdmx/flutter-quill/pull/2413).
- **BREAKING**: Replace `QuillClipboardConfig.onDeltaPaste` with `QuillClipboardConfig.onRichTextPaste` which is more specific and provides an additional parameter `isExternal` to determine whether the `Delta` content is from an external app.
- Bosnian (bs), Macedonian (mk) and Gujarati (gu) language translations [#2455](https://github.com/singerdmx/flutter-quill/pull/2455).
- `textSpanBuilder` to `QuillEditorConfig` to allow overriding how text content is rendered.

### Removed

- **BREAKING**: The quill shared configuration class.
- The dependency [equatable](https://pub.dev/packages/equatable).
- The experimental support for spell checking. See [#2246](https://github.com/singerdmx/flutter-quill/issues/2246).
- **BREAKING**: The magnifier feature due to buggy behavior [#2413](https://github.com/singerdmx/flutter-quill/pull/2413). See [#2406](https://github.com/singerdmx/flutter-quill/issues/2406) for a list of reasons.

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

[unreleased]: https://github.com/singerdmx/flutter-quill/compare/v11.5.0...HEAD
[11.5.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.5.0
[11.4.2]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.4.2
[11.4.1]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.4.1
[11.4.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.4.0
[11.3.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.3.0
[11.2.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.2.0
[11.1.2]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.1.2
[11.1.1]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.1.1
[11.1.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.1.0
[11.0.0]: https://github.com/singerdmx/flutter-quill/compare/v10.0.0...v11.0.0
[10.8.5]: https://github.com/singerdmx/flutter-quill/compare/v9.4.0...v10.8.5
[9.4.0]: https://github.com/singerdmx/flutter-quill/releases/tag/v9.4.0
