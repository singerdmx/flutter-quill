# Flutter Quill - Project Analysis

## Overview

**Flutter Quill** is a rich text editor (WYSIWYG) for Flutter applications, built for Android, iOS, Web, and desktop platforms. It's based on the Quill Delta format and provides a comprehensive text editing experience with formatting, embeds, and extensive customization options.

- **Version**: 11.5.0
- **License**: MIT
- **SDK Requirements**: Dart >=3.0.0, Flutter >=3.0.0
- **Repository**: https://github.com/singerdmx/flutter-quill

## Project Structure

### Core Packages

1. **`flutter_quill`** (Main Package)
   - Core editor functionality
   - Document model and Delta operations
   - Editor widgets and toolbar
   - Controller and state management

2. **`flutter_quill_extensions`** (Extension Package)
   - Image and video embed support
   - Additional embed builders
   - Extended toolbar buttons

3. **`flutter_quill_test`** (Testing Package)
   - Testing utilities for Flutter Quill
   - Widget testing helpers

### Directory Structure

```
lib/
├── flutter_quill.dart          # Main library export
├── quill_delta.dart            # Delta format re-export
└── src/
    ├── common/                 # Shared utilities and structs
    ├── controller/             # QuillController and clipboard handling
    ├── delta/                  # Delta diff utilities
    ├── document/               # Document model and nodes
    ├── editor/                 # Editor widgets and rendering
    ├── editor_toolbar_controller_shared/  # Shared editor/toolbar logic
    ├── l10n/                   # Localization (104 files, 54 languages)
    ├── packages/                # Package integrations (markdown)
    ├── rules/                  # Business logic rules
    └── toolbar/                # Toolbar widgets and buttons
```

## Architecture

### 1. Document Model

The document is represented as a tree structure:

- **Root**: Top-level container
- **Block**: Groups of lines with same block style (blockquote, header, indent, list, etc.)
- **Line**: Represents a line of text with formatting
- **Leaf**: Text segments or embeds within a line
- **Embeddable**: Special nodes for images, videos, custom embeds

**Key Classes:**
- `Document`: Main document class managing Delta operations
- `Node`: Abstract base for all document nodes
- `Container`: Base for nodes that contain children
- `Block`: Container for lines with block-level formatting
- `Line`: Container for text segments and embeds
- `Leaf`: Text or embed content

### 2. Delta Format

The project uses **Quill Delta** format for document representation:
- Compact JSON format for describing document changes
- Operations: `insert`, `delete`, `retain`
- Attributes stored with operations for formatting
- Serialization: `Document.toDelta()` and `Document.fromDelta()`

### 3. Controller Pattern

**QuillController** manages:
- Document state and selection
- Text editing operations (insert, delete, format)
- Clipboard operations (copy, cut, paste)
- Undo/redo history
- Style toggling
- Change notifications

**Key Methods:**
- `replaceText()`: Insert/replace text or embeds
- `formatText()`: Apply formatting attributes
- `updateSelection()`: Manage cursor/selection
- `clipboardPaste()`: Handle paste operations
- `undo()`/`redo()`: History management

### 4. Editor Widgets

**QuillEditor**:
- Main editor widget
- Handles rendering, selection, gestures
- Integrates with Flutter's text editing system
- Supports custom embed builders
- Platform-specific behaviors (iOS, Android, Web, Desktop)

**QuillSimpleToolbar**:
- Pre-built toolbar with common formatting buttons
- Highly configurable (show/hide buttons, custom buttons)
- Supports horizontal/vertical layouts
- Customizable themes and icons

### 5. Rules System

Business logic for document operations:
- **Insert Rules**: Handle text/embed insertion
- **Delete Rules**: Handle deletion operations
- **Format Rules**: Handle formatting operations
- Custom rules can be added via `Document.setCustomRules()`

### 6. Embed System

Extensible system for custom content:
- **EmbedBuilder**: Interface for rendering embeds
- **Embeddable**: Base class for embed data
- Built-in support: Images, Videos (via extensions)
- Custom embeds can be implemented

## Key Features

### Text Formatting
- **Inline**: Bold, Italic, Underline, Strikethrough, Code, Subscript, Superscript
- **Block**: Headers, Lists (ordered, unordered, check), Blockquote, Code blocks
- **Styles**: Font family, Font size, Text color, Background color
- **Alignment**: Left, Center, Right, Justify
- **Advanced**: Line height, Indentation, Text direction (RTL)

### Clipboard Operations
- Rich text paste from other apps
- HTML/Markdown paste support
- Image paste support
- Internal copy/paste with style retention
- Platform-specific clipboard handling

### Search & Navigation
- Built-in search functionality
- Search within embeds (configurable)
- Case-sensitive and whole-word options

### Localization
- 54 language translations (ARB files)
- Follows system locale
- Customizable localization delegates

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## Dependencies

### Core Dependencies
- `dart_quill_delta`: Delta format operations
- `flutter_localizations`: Localization support
- `html`: HTML parsing
- `intl`: Internationalization
- `flutter_colorpicker`: Color selection
- `flutter_quill_delta_from_html`: HTML to Delta conversion
- `markdown`: Markdown support

### Platform Plugins
- `url_launcher`: Open links
- `quill_native_bridge`: Platform-specific APIs
- `flutter_keyboard_visibility_temp_fork`: Keyboard visibility

### Extension Dependencies
- `photo_view`: Image viewing
- `video_player`: Video playback
- `image_picker`: Image selection

## Configuration & Customization

### Editor Configuration
- `QuillEditorConfig`: Editor appearance and behavior
- Custom styles, padding, placeholder
- Embed builders
- Search configuration
- Keyboard shortcuts
- Context menu customization

### Toolbar Configuration
- `QuillSimpleToolbarConfig`: Toolbar appearance
- Show/hide specific buttons
- Custom buttons
- Theme customization
- Layout options (horizontal/vertical, multi-row)

### Controller Configuration
- `QuillControllerConfig`: Clipboard handling
- Rich text paste settings
- Image/GIF paste callbacks
- Custom paste handlers

## Testing

- **Unit Tests**: Document operations, Delta operations
- **Widget Tests**: Editor and toolbar widgets
- **Integration Tests**: End-to-end editor functionality
- **Test Package**: `flutter_quill_test` provides testing utilities

## Recent Changes (v11.x)

### Breaking Changes
- Configuration class names changed to use `Config` suffix
- Embed block interface refactored
- Clipboard buttons disabled by default
- Removed magnifier feature (buggy behavior)
- Removed spell checking support
- Minimum SDK: Flutter 3.0/Dart 3.0

### New Features
- `textSpanBuilder` for custom text rendering
- `onKeyPressed` callback for key handling
- Improved link validation with `validateLink` callback
- Better read-only mode support
- iOS magnifier support using `RawMagnifier`
- Caching for `toPlainText()` performance

### Bug Fixes
- Fixed clipboard image pasting on Android
- Fixed desktop app crashes with Flutter 3.32.0+
- Fixed text selection in read-only mode
- Fixed color picker hex field value

## Code Quality

- **Linting**: Uses `flutter_lints` ^5.0.0
- **Documentation**: Extensive inline documentation
- **Type Safety**: Strong typing throughout
- **Error Handling**: Assertions and error messages
- **Platform Detection**: Utilities for platform-specific code

## Development Workflow

### Scripts
- `before_push.dart`: Pre-push checks
- `publish_flutter_quill.dart`: Publishing automation
- `regenerate_translations.dart`: Translation management
- `update_changelog_version.dart`: Changelog updates
- `update_pubspec_version.dart`: Version management

### Example App
Located in `example/` directory:
- Demonstrates basic usage
- Shows advanced configurations
- Custom embed examples
- Integration with extensions

## Best Practices

1. **Always dispose controllers**: `controller.dispose()` in widget dispose
2. **Use localization delegates**: Add `FlutterQuillLocalizations.delegate`
3. **Handle clipboard paste**: Configure `QuillClipboardConfig` for image handling
4. **Custom embeds**: Implement `EmbedBuilder` for custom content
5. **Delta storage**: Store documents as Delta JSON, not HTML
6. **Platform setup**: Configure Android FileProvider for image clipboard

## Known Limitations

- Rich text paste not supported on Web (issues #1998, #2220)
- Some advanced features require platform-specific setup
- Spell checking removed (experimental support discontinued)
- Magnifier feature removed due to bugs

## Contributing

The project prioritizes:
- Bug fixes
- Code quality improvements
- Over new features (large feature PRs may not be merged)

Guidelines:
- Follow CONTRIBUTING.md
- Create issues before large changes
- Maintain code consistency
- Add tests for new features

## Resources

- **Documentation**: `/doc` directory
- **Code Introduction**: `doc/code_introduction.md`
- **Migration Guide**: `doc/migration/10_to_11.md`
- **YouTube Playlist**: Code walkthrough videos
- **Slack Group**: Community discussions

## Summary

Flutter Quill is a mature, well-architected rich text editor with:
- Strong document model based on Quill Delta
- Extensible embed system
- Comprehensive formatting options
- Multi-platform support
- Active maintenance and community

The codebase is organized, well-documented, and follows Flutter best practices. The modular architecture allows for easy customization and extension.
