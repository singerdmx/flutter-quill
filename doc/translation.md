# Translation

The package offers translations for the quill toolbar and editor, it will follow the locale that is defined in your `WidgetsApp` for example `MaterialApp` which usually follows the system locally unless you set your own locale with:

```dart
 QuillProvider(
  configurations: QuillConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(
      locale: Locale('fr'), // will take affect only if FlutterQuillLocalizations.delegate is not defined in the Widget app
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
* `Locale('he')`, `Locale('zh', 'CN')`, `Locale('zh', 'HK')`, `Locale('ko')`
* `Locale('ru')`, `Locale('es')`, `Locale('tk')`, `Locale('tr')`
* `Locale('uk')`, `Locale('ur')`, `Locale('pt')`, `Locale('pl')`
* `Locale('vi')`, `Locale('id')`, `Locale('it')`, `Locale('ms')`
* `Locale('nl')`, `Locale('no')`, `Locale('fa')`, `Locale('hi')`
* `Locale('sr')`, `Locale('sw')`, `Locale('ja')`

#### Contributing to translations

The translation files are located in the [l10n folder](../lib/src/l10n/). Feel free to contribute your own translations, just copy the [English translations](../lib/src/l10n/quill_en.arb) map and replace the values with your translations.

Add a new file in the l10n folder with the following name
`quill_${localName}.arb` for example `quill_de.arb`

paste the English version and replace the values

Also, you can take a look at the [untranslated.json](../lib/src/l10n/untranslated.json) JSON file, which is a generated file that tells you which keys with which locales haven't translated so you can find the missings easily

After you are done and want to test the changes, run the following in the root folder (preferred):

```
flutter gen-l10n
```

or:

```
./scripts/regenerate-translations.sh
```


This will generate the new dart files from the arb files in order to take effect, otherwise, you won't notice a difference

 Then open a pull request so everyone can benefit from your translations!
