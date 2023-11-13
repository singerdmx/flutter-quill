# Custom `QuillToolbar` Buttons

You may add custom buttons to the _end_ of the toolbar, via the `customButtons` option, which is a `List` of `QuillToolbarCustomButtonOptions`.

To add an Icon, we should use a new `QuillToolbarCustomButtonOptions` class

```dart
    QuillToolbarCustomButtonOptions(
        icon: const Icon(Icons.ac_unit),
        tooltip: '',
        onPressed: () {},
        afterButtonPressed: () {},
      ),
```

Each `QuillCustomButton` is used as part of the `customButtons` option as follows:

```dart
QuillToolbar(
  configurations: QuillToolbarConfigurations(
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