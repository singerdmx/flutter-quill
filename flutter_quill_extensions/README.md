# Flutter Quill Extensions

Helpers to support embed widgets in flutter_quill. See [Flutter Quill](https://pub.dev/packages/flutter_quill) for details of use.

## Usage

Set the `embedBuilders` and `embedToolbar` params in `QuillEditor` and `QuillToolbar` with the
values provided by this repository.

```
QuillEditor.basic(
  controller: controller,
  embedBuilders: FlutterQuillEmbeds.builders(),
);
```

```
QuillToolbar.basic(
  controller: controller,
  embedButtons: FlutterQuillEmbeds.buttons(),
);
```
