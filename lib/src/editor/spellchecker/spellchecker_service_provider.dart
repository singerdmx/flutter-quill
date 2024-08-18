import 'package:flutter/foundation.dart' show immutable;
import 'default_spellchecker_service.dart';
import 'spellchecker_service.dart';

@immutable
class SpellcheckerServiceProvider {
  const SpellcheckerServiceProvider._();
  static SpellcheckerService _instance = DefaultSpellcheckerService();

  static SpellcheckerService get instance => _instance;

  static void setInstance(SpellcheckerService service) {
    _instance = service;
  }

  static void setInstanceToDefault() {
    _instance = DefaultSpellcheckerService();
  }
}
