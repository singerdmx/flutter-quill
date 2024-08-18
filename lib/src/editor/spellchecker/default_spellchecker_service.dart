import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart' show TextSpan;
import 'spellchecker_service.dart' show SpellcheckerService;

/// A default implementation of the [SpellcheckerService]
/// that always will return null since Spell checking
/// is not a standard feature
class DefaultSpellcheckerService extends SpellcheckerService {
  DefaultSpellcheckerService() : super(language: 'en');

  @override
  void dispose({bool onlyPartial = false}) {}

  @override
  List<TextSpan>? fetchSpellchecker(String text,
      {LongPressGestureRecognizer Function(String p1)?
          customLongPressRecognizerOnWrongSpan}) {
    return null;
  }
}
