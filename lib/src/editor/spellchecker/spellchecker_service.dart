import 'package:flutter/material.dart';

abstract class SpellcheckerService {
  SpellcheckerService({required this.language});

  final String language;
  List<TextSpan>? fetchSpellchecker(String text);
}
