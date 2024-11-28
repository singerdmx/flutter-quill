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

📄 For additional notes, see the [localizations setup](./localizations_setup.md) page.

