# 🌍 Localizations Setup

In addition to the required delegates mentioned above in [Using custom app widget](./using_custom_app_widget.md), which are:

```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
],
```

Which are used by Flutter widgets.

📌 Note: The library also needs the `FlutterQuillLocalizations.delegate`:

```dart
// Required localizations delegates ...
FlutterQuillLocalizations.delegate
```

**You don't have to add this explicitly** because we have wrapped the `QuillEditor` and `QuillToolbar` with `FlutterQuillLocalizationsWidget`. This widget will check if the necessary localizations are set; if not, it will provide them only for these widgets. Therefore, it's not strictly required. However, if you are overriding the `localizationsDelegates`, you can also add the `FlutterQuillLocalizations.delegate`.

📄 For additional notes, refer to the [Translation](../translation.md) section.
