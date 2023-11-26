# Using Custom App Widget

This project uses some adaptive widgets like `AdaptiveTextSelectionToolbar` which require the following delegates:

1. Default Material Localizations delegate
2. Default Cupertino Localizations delegate
3. Default Widgets Localizations delegate

You don't need to include those since they are defined by default
 but if you are using a Custom app or you are overriding the `localizationsDelegates` in the App widget
then please make sure it includes those:

```dart
localizationsDelegates: const [
    DefaultCupertinoLocalizations.delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
],
```

You might need more depending on your use case, for example, if you are using custom localizations for your app, using a custom app widget like `FluentApp` from [FluentUI]
which will also need

```dart
localizationsDelegates: const [
    // Required localizations delegates ...
    FluentLocalizations.delegate,
    AppLocalizations.delegate,
],
```

Note: In the latest versions of `FluentApp` you no longer need to add the `localizationsDelegates` but this is just an example, for more [info](https://github.com/bdlukaa/fluent_ui/pull/946)

There are additional notes on the [Localizations](./localizations_setup.md) page

[FluentUI]: https://pub.dev/packages/fluent_ui
