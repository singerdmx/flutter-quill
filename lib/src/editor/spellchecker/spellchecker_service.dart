import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class SpellcheckerService {
  SpellcheckerService({required this.language});

  final String language;

  void dispose();
  List<TextSpan>? fetchSpellchecker(String text,
      {LongPressGestureRecognizer Function(String)?
          customLongPressRecognizerOnWrongSpan});
}
