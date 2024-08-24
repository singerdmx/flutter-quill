import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

/// SimpleSpellChecker is a simple spell checker for get
/// all words divide on different objects if them are wrong or not
class SimpleSpellCheckerService
    extends SpellCheckerService<LanguageIdentifier> {
  SimpleSpellCheckerService({required super.language})
      : checker = SimpleSpellChecker(
          language: language,
          safeDictionaryLoad: true,
        );

  /// [SimpleSpellChecker] comes from the package [simple_spell_checker]
  /// that give us all necessary methods for get our spans with highlighting
  /// where needed
  final SimpleSpellChecker checker;

  @override
  List<TextSpan>? checkSpelling(
    String text, {
    LongPressGestureRecognizer Function(String word)?
        customLongPressRecognizerOnWrongSpan,
  }) {
    return checker.check(
      text,
      customLongPressRecognizerOnWrongSpan:
          customLongPressRecognizerOnWrongSpan,
    );
  }

  @override
  void toggleChecker() => checker.toggleChecker();

  @override
  bool isServiceActive() => checker.isCheckerActive();

  @override
  void dispose({bool onlyPartial = false}) {
    if (onlyPartial) {
      checker.disposeControllers();
      return;
    }
    checker.dispose();
  }

  @override
  void addCustomLanguage({required languageIdentifier}) {
    checker
      ..registerLanguage(languageIdentifier.language)
      ..addCustomLanguage(languageIdentifier);
  }

  @override
  void setNewLanguageState({required String language}) {
    checker.setNewLanguageToState(language);
  }

  @override
  void updateCustomLanguageIfExist({required languageIdentifier}) {
    checker.updateCustomLanguageIfExist(languageIdentifier);
  }
}
