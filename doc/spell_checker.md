# 📝 Spelling checker

A spell checker is a software tool or feature integrated into various text processing applications that automatically identifies and corrects spelling errors in a written document. It works by comparing the words in the text against a built-in dictionary. If a word isn't found in the dictionary or doesn't match any known word patterns, the spell checker highlights it as a potential error.

While spell-checking is not a feature that's implemented into the project, it can be used using external dependencies.

It's implemented using the package `simple_spell_checker` in the [Example](../example/).

### Benefits of a spell checker include:

* Improved Accuracy: It helps writers avoid common spelling mistakes, ensuring that the text is free of errors.
* Time-Saving: Automatically detecting errors reduces the time needed for manual proofreading.
* Enhanced Professionalism: Correctly spelled words contribute to the overall professionalism of documents, which is crucial in academic, business, and formal writing.
* Multilingual Support: Many spell checkers support multiple languages, making it easier for users to write accurately in different languages.

> [!IMPORTANT]
> The spell checker usually does not work as expected in most cases. **Many translations are not supported** such as: `Chinese`, `Japanese`, `Korean`, `Hebrew`, `Arabic`, `Russian`, etc. For now it is a purely **experimental** feature that may have **code that will be modified** in future versions.

### The translations supported so far are:

* **German** - `de` (may contain errors or missing words)
* **English** - `en` (currently adding missing translations)
* **Spanish** - `es` (currently adding missing translations)
* **French** - `fr` (may contain errors or missing words)
* **Italian** - `it` (currently adding missing translations)
* **Norwegian** - `no` (may contain errors or missing words)
* **Portuguese** - `pt` (may contain errors or missing words)
* **Swedish** - `sv` (may contain errors or missing words)

_**Note**: If you have knowledge about any of these available languages or the unsupported ones, you can make a pull request to add support or add words that are not currently in [simple_spell_checker](https://github.com/CatHood0/simple_spell_checker)_.

In order to activate this functionality you can use the following code:

```dart
// you can use the language of your preference or directly select the language of the operating system
final language = 'en'; // or Localizations.localeOf(context).languageCode
SpellChecker.useSpellCheckerService(language);
```

> [!NOTE]
> The class `SpellChecker` is not available as part of the project API. Instead, you will have to implement it manually. Take a look at the example [Spell Checker](../example/lib/spell_checker/spell_checker.dart) class.

When you no longer need to have the Spell checker activated you can simply use `dispose()` of the `SpellCheckerServiceProvider` class:

```dart
// dispose all service and it cannot be used after this
SpellCheckerServiceProvider.dispose();
```

If what we want is to **close the StreamControllers** without deleting the values that are already stored in it, we can set `onlyPartial` to `true`.

```dart
// it can be still used by the editor
SpellCheckerServiceProvider.dispose(onlyPartial: true);
```

One use of this would be having the opportunity to **activate and deactivate** the service when we want, we can see this in the example that we have in this package, in which you can see that on each screen, we have a button that dynamically activates and deactivates the service. To do this is pretty simple:

```dart
 SpellCheckerServiceProvider.toggleState();
 // use isServiceActive to get the state of the service
 SpellCheckerServiceProvider.isServiceActive();
 setState(() {});
```

Open this [page](https://pub.dev/packages/simple_spell_checker) for more information.