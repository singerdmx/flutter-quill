# 🔘 Custom `QuillSimpleToolbar` Buttons

You may add custom buttons to the _end_ of the toolbar, via the `customButtons` option, which is a `List`
of `QuillToolbarCustomButtonOptions`.

## Adding an Icon 🖌️

To add an Icon:

```dart
    QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        tooltip: 'Tooltip',
        onPressed: () {},
      ),
```

## Example Usage 📚

Each `QuillCustomButton` is used as part of the `customButtons` option as follows:

```dart
QuillSimpleToolbar(
  controller: _controller,
  config: QuillSimpleToolbarConfig(
    customButtons: [
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake1');
        },
      ),
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake2');
        },
      ),
      QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        onPressed: () {
          debugPrint('snowflake3');
        },
      ),
    ],
  ),
),
```