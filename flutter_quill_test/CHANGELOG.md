# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The [previous `CHANGELOG.md`](https://github.com/singerdmx/flutter-quill/blob/master/doc/OLD_CHANGELOG.md) has been archived.

## [Unreleased]

## [11.1.0] - 2025-03-19

### Added

- Add more APIs for testing [#2512](https://github.com/singerdmx/flutter-quill/pull/2512).
- Replace text with `quillReplaceText` and `quillReplaceTextWithSelection`.
- Delete text with `quillRemoveText` and `quillRemoveTextInSelection`.
- Insert text at the specified position with `quillEnterTextAtPosition`.
- Update the edit text value with a `TextSelection` using `quillUpdateEditingValueWithSelection`.
- Get the current `TextEditingValue` using `getTextEditingValue`.
- Move the cursor with `quillMoveCursorTo`, `quillUpdateSelection`, and `quillExpandSelectionTo`.
- Simulate hiding the keyboard using `quillHideKeyboard`.
- Find the `QuillEditor` or `QuillRawEditorState` using `findRawEditor` and `findEditor`.

## [11.0.0] - 2025-02-17

### Changed

- Improve pub topics in package metadata.
- Separate the package version and `CHANGELOG.md` from [flutter_quill](https://pub.dev/packages/flutter_quill).

