import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A representation a custom SpellCheckService.
abstract class SpellCheckerService<T> {
  SpellCheckerService({required this.language});

  final String language;

  /// Decide if the service should be activate or deactivate
  /// without dispose the service
  void toggleChecker();

  bool isServiceActive();

  /// dispose all the resources used for SpellcheckerService
  ///
  /// if [onlyPartial] is true just dispose a part of the SpellcheckerService
  /// (this comes from the implementation)
  ///
  /// if [onlyPartial] is false dispose all resources
  void dispose({bool onlyPartial = false});

  /// set a new language state used for SpellcheckerService
  void setNewLanguageState({required String language});

  /// set a new language state used for SpellcheckerService
  void updateCustomLanguageIfExist({required T languageIdentifier});

  /// set a new custom language for SpellcheckerService
  void addCustomLanguage({required T languageIdentifier});

  /// Facilitates a spell check request.
  ///
  /// Returns a [List<TextSpan>] with all misspelled words divide from the right words.
  List<TextSpan>? checkSpelling(String text,
      {LongPressGestureRecognizer Function(String)?
          customLongPressRecognizerOnWrongSpan});
}
