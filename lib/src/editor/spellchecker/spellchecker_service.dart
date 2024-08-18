import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A representation a custom SpellCheckService.
abstract class SpellcheckerService {
  SpellcheckerService({required this.language});

  final String language;

  /// dispose all the resources used for SpellcheckerService
  ///
  /// if [onlyPartial] is true just dispose a part of the SpellcheckerService
  /// (this comes from the implementation)
  ///
  /// if [onlyPartial] is false dispose all resources
  void dispose({bool onlyPartial = false});

  /// Facilitates a spell check request.
  ///
  /// Returns a [List<TextSpan>] with all misspelled words divide from the right words.
  List<TextSpan>? fetchSpellchecker(String text,
      {LongPressGestureRecognizer Function(String)?
          customLongPressRecognizerOnWrongSpan});
}
