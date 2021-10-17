import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale('en') +
      {
        'en': {
          'Paste a link': 'Paste a link',
          'Ok': 'Ok',
          'Select Color': 'Select Color',
          'Gallery': 'Gallery',
          'Link': 'Link',
        },
        'de': {
          'Paste a link': 'Link hinzufügen',
          'Ok': 'Ok',
          'Select Color': 'Farbe auswählen',
          'Gallery': 'Gallerie',
          'Link': 'Link',
        },
        'fr': {
          'Paste a link': 'Coller un lien',
          'Ok': 'Ok',
          'Select Color': 'Choisir une couleur',
          'Gallery': 'Galerie',
          'Link': 'Lien',
        },
        'zh_CN': {
          'Paste a link': '粘贴链接',
          'Ok': '好',
          'Select Color': '选择颜色',
          'Gallery': '相簿',
          'Link': '链接',
        }
      };

  String get i18n => localize(this, _t);
}
