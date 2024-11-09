# 🔠 Font Size

Within the editor toolbar, a drop-down with font-sizing capabilities is available.
This can be enabled or disabled with `showFontSize`.

When enabled, the default font-size values can be modified via _optional_ `rawItemsMap`.
Accepts a `Map<String, String>` consisting of a `String` title for the font size and a `String` value for the font size.
Example:

```dart
QuillSimpleToolbar(
    config: const QuillSimpleToolbarConfig(
      buttonOptions: QuillSimpleToolbarButtonOptions(
        fontSize: QuillToolbarFontSizeButtonOptions(
          items: {'Small': '8', 'Medium': '24.5', 'Large': '46'},
        ),
      ),
    ),
  );
```

Font size can be cleared with a value of `0`, for example:

```dart
QuillSimpleToolbar(
    config: const QuillSimpleToolbarConfig(
      buttonOptions: QuillSimpleToolbarButtonOptions(
        fontSize: QuillToolbarFontSizeButtonOptions(
          items: {'Small': '8', 'Medium': '24.5', 'Large': '46', 'Clear': '0'},
        ),
      ),
    ),
  );
```