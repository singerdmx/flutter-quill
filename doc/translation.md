# Translation

The package offers translations for the quill toolbar and editor, it will follow the system locale unless you set your own locale with:

```dart
 QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(
      locale: Locale('fr'),
    ),
  ),
  child: Column(
    children: [
      const QuillToolbar(
        configurations: QuillToolbarConfigurations(),
      ),
      Expanded(
        child: QuillEditor.basic(
          configurations: const QuillEditorConfigurations(),
        ),
      )
    ],
  ),
)
```

Currently, translations are available for these 31 locales:

* `Locale('en')`, `Locale('ar')`, `Locale('bn')`, `Locale('bs')`
* `Locale('cs')`, `Locale('de')`, `Locale('da')`, `Locale('fr')`
* `Locale('he')`, `Locale('zh', 'cn')`, `Locale('zh', 'hk')`, `Locale('ko')`
* `Locale('ru')`, `Locale('es')`, `Locale('tk')`, `Locale('tr')`
* `Locale('uk')`, `Locale('ur')`, `Locale('pt')`, `Locale('pl')`
* `Locale('vi')`, `Locale('id')`, `Locale('it')`, `Locale('ms')`
* `Locale('nl')`, `Locale('no')`, `Locale('fa')`, `Locale('hi')`
* `Locale('sr')`, `Locale('sw')`, `Locale('ja')`

#### Contributing to translations

The translation file is located at [toolbar.i18n.dart](lib/src/translations/toolbar.i18n.dart). Feel free to contribute your own translations, just copy the English translations map and replace the values with your translations. Then open a pull request so everyone can benefit from your translations!