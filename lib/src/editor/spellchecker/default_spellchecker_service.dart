import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart' show TextSpan;
import 'spellchecker_service.dart' show SpellcheckerService;

class DefaultSpellcheckerService extends SpellcheckerService {
  DefaultSpellcheckerService() : super(language: 'en');

  @override
  void dispose() {}

  @override
  List<TextSpan>? fetchSpellchecker(String text,
      {LongPressGestureRecognizer Function(String p1)?
          customLongPressRecognizerOnWrongSpan}) {
    return null;
  }
}
