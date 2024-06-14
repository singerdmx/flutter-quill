# Translation

The package offers translations for the quill toolbar and editor, it will follow the locale that is defined in your `WidgetsApp` for example `MaterialApp` which usually follows the system locally unless you set your own locale with:

```dart
QuillToolbar.simple(
  configurations: QuillSimpleToolbarConfigurations(
    controller: _controller,
    sharedConfigurations: const QuillSharedConfigurations(
      locale: Locale('de'),
    ),
  ),
),
Expanded(
  child: QuillEditor.basic(
    configurations: QuillEditorConfigurations(
      controller: _controller,
      sharedConfigurations: const QuillSharedConfigurations(
        locale: Locale('de'),
      ),
    ),
  ),
)
```

Currently, translations are available for these 37 locales:

* `Locale('en')`, `Locale('ar')`, `Locale('bn')`, `Locale('bs')`
* `Locale('cs')`, `Locale('de')`, `Locale('da')`, `Locale('fr')`
* `Locale('he')`, `Locale('zh', 'CN')`, `Locale('zh', 'HK')`
* `Locale('ko')`, `Locale('ku')`, `Locale('ku', 'CKB')`
* `Locale('ro', 'RO')`, `Locale('ru')`, `Locale('es')`, `Locale('tk')`, `Locale('tr')`
* `Locale('uk')`, `Locale('ur')`, `Locale('pt')`, `Locale('pl')`
* `Locale('vi')`, `Locale('id')`, `Locale('it')`, `Locale('ms')`
* `Locale('nl')`, `Locale('no')`, `Locale('ne', 'NP')`, `Locale('fa')`, `Locale('hi')`
* `Locale('sk')`, `Locale('sr')`, `Locale('sv')`, `Locale('sw')`, `Locale('ja')`

#### Contributing to translations

The translation files are located in the [l10n folder](../lib/src/l10n/). Feel free to contribute your own translations.

You can take a look at the [untranslated.json](../lib/src/l10n/untranslated.json) file, which is a generated file that tells you which keys with which locales haven't translated so you can find the missings easily.

1. Create a new file in [l10n](../lib/src/l10n/) folder, with the following name`quill_${localName}.arb` for example `quill_de.arb`

2. Copy the [Arb Template](../lib/src/l10n/quill_en.arb) file and paste it into your new file, replace the values with your translations

3. Once you finish, run the following script:

    ```bash
    dart ./scripts/regenerate_translations.dart
    ```

    Or (if you can't run the script for some reason):

    ```bash
    flutter gen-l10n
    dart fix --apply ./lib/src/l10n/generated
    dart format ./lib/src/l10n/generated
    ```

The script above will generate Dart files from the Arb files in order to test the changes and take effect, otherwise you won't notice a difference.

> If you added or removed translations in the template file, make sure to update `_expectedTranslationKeysLength` variable in `./scripts/ensure_translations_correct.dart` <br>
> Otherwise you don't need to update it.

Then open a pull request so everyone can benefit from your translations!
