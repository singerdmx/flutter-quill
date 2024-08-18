import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

import 'spellchecker_service.dart';

class SimpleSpellCheckerImpl extends SpellcheckerService {
  SimpleSpellCheckerImpl({required super.language})
      : checker = SimpleSpellChecker(
          language: language,
          safeDictionaryLoad: true,
        );
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
  void dispose() {
    checker.dispose(closeDirectionary: true);
  }
}
