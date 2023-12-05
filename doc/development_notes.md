# Development notes

- When updating the translations or localizations in the app, please take a look at the [Translation](./translation.md) page as it has important notes in order to work, if you also add a feature that adds new localizations then you need to the instructions of it in order for the translations to take effect
- Only update the `version.dart` and `CHANGELOG.md` at the root folder of the repo, then run the script:

    ```console
    dart ./scripts/regenerate_versions.dart
    ```
    You must mention the changes of the other packages in the repo in the root `CHANGELOG.md` only and the script will replace the `CHANGELOG.md` in the other packages with the root one, and change the version in `pubspec.yaml` with the one in `version.dart` in the root folder