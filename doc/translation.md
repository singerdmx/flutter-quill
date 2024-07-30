# 🌍 Translation

The package offers translations for the quill toolbar and editor, it will follow the locale that is defined in
your `WidgetsApp` for example `MaterialApp` which usually follows the system locally unless you set your own locale
with:

```dart
QuillToolbar.simple(
  controller: _controller,
  configurations: QuillSimpleToolbarConfigurations(
    sharedConfigurations: const QuillSharedConfigurations(
      locale: Locale('de'),
    ),
  ),
),
Expanded(
  child: QuillEditor.basic(
    controller: _controller,
    configurations: QuillEditorConfigurations(
      sharedConfigurations: const QuillSharedConfigurations(
        locale: Locale('de'),
      ),
    ),
  ),
)
```

## 🌐 Supported Locales

Currently, translations are available for these 41 locales:

* `ar`, `bg`, `bn`, `ca`, `cs`, `da`, `de`
* `en`, `en_US`, `es`, `fa`, `fr`, `he`
* `hi`, `id`, `it`, `ja`, `ko`, `ku`
* `ms`, `ne`, `nl`, `no`, `pl`, `pt`
* `pt_BR`, `ro`, `ro_RO`, `ru`, `sk`, `sr`
* `sv`, `sw`, `tk`, `tr`, `uk`, `ur`
* `vi`, `zh`, `zh_CN`, `zh_HK`

## 📌 Contributing to translations

The translation files are located in the [l10n](../lib/src/l10n/) folder. Feel free to contribute your own translations.

You can take a look at the [untranslated.json](../lib/src/l10n/untranslated.json) file, which is a generated file that
tells you which keys with which locales haven't been translated so you can find the missing easily.

<details>
<summary>Add new local</summary>

1. Create a new file in [l10n](../lib/src/l10n/) folder, with the following name`quill_${localName}.arb` for
   example `quill_de.arb`. See [locale codes](https://saimana.com/list-of-country-locale-code/).

2. Copy the [Arb Template](../lib/src/l10n/quill_en.arb) file and paste it into your new file, replace the values with
   your translations

3. Update the [Supported Locales](#supported-locales) section on this page to update the supported translations for both the
   number and the list

</details>

<details>
<summary>Update existing local</summary>

1. Navigate to [l10n](../lib/src/l10n/) folder

2. Find the existing local, let's say you want to update the Korean translations, it will be `quill_ko.arb`

3. Use [untranslated.json](../lib/src/l10n/untranslated.json) as a reference to find missing, update, or add what you
   want
   to translate.

</details>
<br>

> We usually avoid **updating the existing value of a key in the template file without updating the key or creating a new
one**.
> This will not update the [untranslated.json](../lib/src/l10n/untranslated.json) correctly and will make it harder
for contributors to find missing or incomplete.

Once you finish, run the following script:

```bash
dart ./scripts/regenerate_translations.dart
```

Or (if you can't run the script for some reason):

```bash
flutter gen-l10n
dart fix --apply ./lib/src/l10n/generated
dart format ./lib/src/l10n/generated
```

The script above will generate Dart files from the Arb files to test the changes and take effect, otherwise you
won't notice a difference.

> 🔧 If you added or removed translations in the template file, make sure to update `_expectedTranslationKeysLength`
> variable in [scripts/ensure_translations_correct.dart](../scripts/ensure_translations_correct.dart) <br>
> Otherwise you don't need to update it.

Then open a pull request so everyone can benefit from your translations!
