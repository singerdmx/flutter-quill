import 'package:flutter/services.dart';

abstract class SpellcheckerService {
  SpellcheckerService({
    required this.language,
  });

  final String language;
  List<SuggestionSpan>? getSuggestions(String text);
}


