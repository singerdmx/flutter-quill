import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart' show TextSpan;
import 'spellchecker_service.dart' show SpellCheckerService;

/// A default implementation of the [SpellcheckerService]
/// that always will return null since Spell checking
/// is not a standard feature
class DefaultSpellCheckerService extends SpellCheckerService<Object?> {
  DefaultSpellCheckerService() : super(language: 'en');

  @override
  void dispose({bool onlyPartial = false}) {}

  @override
  List<TextSpan>? checkSpelling(
    String text, {
    LongPressGestureRecognizer Function(String p1)?
        customLongPressRecognizerOnWrongSpan,
  }) {
    return null;
  }

  @override
  void addCustomLanguage({languageIdentifier}) {}

  @override
  void setNewLanguageState({required String language}) {}

  @override
  void updateCustomLanguageIfExist({languageIdentifier}) {}

  @override
  bool isServiceActive() => false;

  @override
  void toggleChecker() {}
}
