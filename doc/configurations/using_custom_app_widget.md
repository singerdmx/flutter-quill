# 🛠️ Using Custom App Widget

The project uses some adaptive widgets like `AdaptiveTextSelectionToolbar` which require the following delegates:

1. Default Material Localizations delegate
2. Default Cupertino Localizations delegate
3. Default Widgets Localizations delegate

You don't need to include these since they are defined by default. However, if you are using a custom app or overriding the `localizationsDelegates` in the App widget, ensure it includes the following:

```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
],
```


You might need more depending on your use case. For example, if you are using custom localizations for your app with a custom app widget like `FluentApp` from [FluentUI], you will also need:

```dart
localizationsDelegates: const [
    // Required localizations delegates ...
    FluentLocalizations.delegate,
    AppLocalizations.delegate,
],
```

📌 Note: In recent versions of `FluentApp`, you no longer need to add the `localizationsDelegates`. This is just an example. For more information, refer to the [#946](https://github.com/bdlukaa/fluent_ui/pull/946).

📄 For additional notes, see the [Localizations](./localizations_setup.md) page.

[FluentUI]: https://pub.dev/packages/fluent_ui
