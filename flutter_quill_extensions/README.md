# Flutter Quill Extensions

Helpers to support embed widgets in flutter_quill.

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
