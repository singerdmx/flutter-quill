import 'package:flutter/material.dart';
import 'spellchecker_service.dart';

class DefaultSpellcheckerService extends SpellcheckerService{
  DefaultSpellcheckerService() : super(language: 'en');

  @override
  List<TextSpan>? fetchSpellchecker(String text) {
    return null;
  }
}
