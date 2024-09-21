// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart' show TextSpan;
import 'package:meta/meta.dart';
import 'spellchecker_service.dart' show SpellCheckerService;

/// A default implementation of the [SpellcheckerService]
/// that always will return null since Spell checking
/// is not a standard feature
@Deprecated(
  'A breaking change is being planned for the SpellCheckerService and SpellCheckerServiceProvider.\n'
  "A replacement doesn't exist yet but should arrive soon."
  'See https://github.com/singerdmx/flutter-quill/issues/2246 for more details.',
)
@experimental
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
