import 'package:flutter/material.dart';

import 'spellchecker_service.dart';

class SimpleSpellCheckerImpl extends SpellcheckerService {
  SimpleSpellCheckerImpl({required super.language});

  @override
  List<TextSpan>? fetchSpellchecker(String text) {
    return null;
  }

}
