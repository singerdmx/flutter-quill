// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart' show immutable;
import 'package:meta/meta.dart' show experimental;
import 'default_spellchecker_service.dart';
import 'spellchecker_service.dart';

@immutable
@Deprecated(
  'A breaking change is being planned for the SpellCheckerService and SpellCheckerServiceProvider.\n'
  "A replacement doesn't exist yet but should arrive soon."
  'See https://github.com/singerdmx/flutter-quill/issues/2246 for more details.',
)
@experimental
class SpellCheckerServiceProvider {
  const SpellCheckerServiceProvider._();
  static SpellCheckerService _instance = DefaultSpellCheckerService();

  static SpellCheckerService get instance => _instance;

  static void setNewCheckerService(SpellCheckerService service) {
    _instance = service;
  }

  static void dispose({bool onlyPartial = false}) {
    _instance.dispose(onlyPartial: onlyPartial);
  }

  static void toggleState() {
    _instance.toggleChecker();
  }

  static bool isServiceActive() {
    return _instance.isServiceActive();
  }

  static void setNewLanguageState({required String language}) {
    assert(language.isNotEmpty);
    _instance.setNewLanguageState(language: language);
  }

  static void turnOffService() {
    _instance = DefaultSpellCheckerService();
  }
}
