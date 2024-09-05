import 'package:flutter_quill/flutter_quill.dart';

import 'simple_spell_checker_service.dart';

class SpellChecker {
  SpellChecker._();

  /// override the default implementation of [SpellCheckerServiceProvider]
  /// to allow a `flutter quill` support a better check spelling
  ///
  /// # !WARNING
  /// To avoid memory leaks, ensure to use [dispose()] method to
  /// close stream controllers that used by this custom implementation
  /// when them no longer needed
  ///
  /// Example:
  ///
  ///```dart
  ///// set partial true if you only need to close the controllers
  ///SpellCheckerServiceProvider.dispose(onlyPartial: false);
  ///```
  static void useSpellCheckerService(String language) {
    SpellCheckerServiceProvider.setNewCheckerService(
      SimpleSpellCheckerService(language: language),
    );
  }
}
