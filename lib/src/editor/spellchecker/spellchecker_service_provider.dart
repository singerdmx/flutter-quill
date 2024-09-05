import 'package:flutter/foundation.dart' show immutable;
import 'default_spellchecker_service.dart';
import 'spellchecker_service.dart';

@immutable
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
