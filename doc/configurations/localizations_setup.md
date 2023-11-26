# Localizations Setup
in addition to the required delegates mentioned above in [Using custom app widget](./using_custom_app_widget.md)

which are:
```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
],
```
which are used by official Flutter widgets

The library also needs the 
```dart
// Required localizations delegates ...
FlutterQuillLocalizations.delegate
```

To offer the default localizations.

But **you don't have to** since we have wrapped the `QuillEditor` and `QuillToolbar` with `FlutterQuillLocalizationsWidget` which will check if it sets then it will go, if not, then it will be provided only for them, so it's not really required, but if you are overriding the `localizationsDelegates` you could also add the `FlutterQuillLocalizations.delegate`
which won't change anything

There are additional notes in the [Translation](../translation.md) section
