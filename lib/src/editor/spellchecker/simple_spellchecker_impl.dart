import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

import 'spellchecker_service.dart';

/// SimpleSpellCheckerImpl is a simple spell checker for get 
/// all words divide on different objects if them are wrong or not
class SimpleSpellCheckerImpl extends SpellcheckerService {
  SimpleSpellCheckerImpl({required super.language})
      : checker = SimpleSpellChecker(
          language: language,
          safeDictionaryLoad: true,
        );
  /// [SimpleSpellChecker] comes from the package [simple_spell_checker]
  /// that give us all necessary methods for get our spans with highlighting
  /// where needed 
  final SimpleSpellChecker checker;

  @override
  List<TextSpan>? fetchSpellchecker(
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
  void dispose({bool onlyPartial = false}) {
    if(onlyPartial) {
      checker.disposeControllers();
      return;
    }
    checker.dispose(closeDirectionary: true);
  }
}
