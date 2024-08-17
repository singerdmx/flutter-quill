import 'package:flutter/services.dart';
import 'spellchecker_service.dart';

class DefaultSpellcheckerService extends SpellcheckerService{
  DefaultSpellcheckerService() : super(language: 'en');

  @override
  List<SuggestionSpan>? getSuggestions(String text) {
    return null;
  }
}
