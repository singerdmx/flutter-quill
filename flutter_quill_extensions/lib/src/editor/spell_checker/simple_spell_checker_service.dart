import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

@Deprecated(
  '''
    Spell checker feature has been removed from the package to make it optional and 
    reduce bundle size. See issue https://github.com/singerdmx/flutter-quill/issues/2142
    for more details.

    Calling this function will not activate the feature.

    This class will be removed in future releases.
    ''',
)
class SimpleSpellCheckerService extends SpellCheckerService<Object?> {
  SimpleSpellCheckerService({required super.language});

  void _featureNoLongerAvailable() => throw UnimplementedError(
        '''
        The spell checker feature has been removed from the package and is now optional.
        See https://github.com/singerdmx/flutter-quill/issues/2142 for more details.
        ''',
      );
  @override
  void addCustomLanguage({required Object? languageIdentifier}) =>
      _featureNoLongerAvailable();

  @override
  List<TextSpan>? checkSpelling(String text,
      {LongPressGestureRecognizer Function(String p1)?
          customLongPressRecognizerOnWrongSpan}) {
    _featureNoLongerAvailable();
    throw UnimplementedError();
  }

  @override
  void dispose({bool onlyPartial = false}) => _featureNoLongerAvailable();

  @override
  bool isServiceActive() {
    _featureNoLongerAvailable();
    throw UnimplementedError();
  }

  @override
  void setNewLanguageState({required String language}) =>
      _featureNoLongerAvailable();

  @override
  void toggleChecker() => _featureNoLongerAvailable();

  @override
  void updateCustomLanguageIfExist({required Object? languageIdentifier}) =>
      _featureNoLongerAvailable();
}
