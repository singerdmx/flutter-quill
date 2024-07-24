import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

bool isRTLLanguage(Locale locale) {
  final rtlLanguages = [
    'ar', // Arabic
    'dv', // Divehi (Maldivian)
    'fa', // Persian (Farsi)
    'ha', // Hausa (in Ajami script)
    'he', // Hebrew
    'khw', // Khowar (in Arabic script)
    'ks', // Kashmiri (in Arabic script)
    'ku', // Kurdish (Sorani)
    'ps', // Pashto
    'ur', // Urdu
    'yi', // Yiddish
    'sd', // Sindhi
    'ug', // Uyghur
  ];
  return rtlLanguages.contains(locale.languageCode);
}

bool isRTL(BuildContext context) {
  return isRTLLanguage(Localizations.localeOf(context));
}
