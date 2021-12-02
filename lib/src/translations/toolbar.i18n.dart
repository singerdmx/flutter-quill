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
          'Please first select some text to transform into a link.':
              'Please first select some text to transform into a link.',
        },
        'ar': {
          'Paste a link': 'نسخ الرابط',
          'Ok': 'نعم',
          'Select Color': 'اختار اللون',
          'Gallery': 'الصور',
          'Link': 'الرابط',
          'Please first select some text to transform into a link.':
              'يرجى اختيار نص للتحويل إلى رابط',
        },
        'de': {
          'Paste a link': 'Link hinzufügen',
          'Ok': 'Ok',
          'Select Color': 'Farbe auswählen',
          'Gallery': 'Gallerie',
          'Link': 'Link',
          'Please first select some text to transform into a link.':
              'Markiere bitte zuerst einen Text, um diesen in einen Link zu '
                  'verwandeln.',
        },
        'fr': {
          'Paste a link': 'Coller un lien',
          'Ok': 'Ok',
          'Select Color': 'Choisir une couleur',
          'Gallery': 'Galerie',
          'Link': 'Lien',
          'Please first select some text to transform into a link.':
              "Veuillez d'abord sélectionner un texte à transformer en lien.",
        },
        'zh_CN': {
          'Paste a link': '粘贴链接',
          'Ok': '好',
          'Select Color': '选择颜色',
          'Gallery': '相簿',
          'Link': '链接',
          'Please first select some text to transform into a link.':
              '请先选择一些要转化为链接的文本',
        },
        'ko': {
          'Paste a link': '링크를 붙여넣어 주세요.',
          'Ok': '확인',
          'Select Color': '색상 선택',
          'Gallery': '갤러리',
          'Link': '링크',
          'Please first select some text to transform into a link.':
              '링크로 전환할 글자를 먼저 선택해주세요.',
        },
        'ru': {
          'Paste a link': 'Вставить ссылку',
          'Ok': 'ОК',
          'Select Color': 'Выбрать цвет',
          'Gallery': 'Галерея',
          'Link': 'Ссылка',
          'Please first select some text to transform into a link.':
              'Выделите часть текста для создания ссылки.',
        },
        'es': {
          'Paste a link': 'Pega un enlace',
          'Ok': 'Ok',
          'Select Color': 'Selecciona un color',
          'Gallery': 'Galeria',
          'Link': 'Enlace',
          'Please first select some text to transform into a link.':
              'Por favor selecciona primero un texto para transformarlo '
                  'en un enlace',
        },
        'tr': {
          'Paste a link': 'Bağlantıyı Yapıştır',
          'Ok': 'Tamam',
          'Select Color': 'Renk Seçin',
          'Gallery': 'Galeri',
          'Link': 'Bağlantı',
          'Please first select some text to transform into a link.':
              'Lütfen bağlantıya dönüştürmek için bir metin seçin.',
        },
        'uk': {
          'Paste a link': 'Вставити посилання',
          'Ok': 'ОК',
          'Select Color': 'Вибрати колір',
          'Gallery': 'Галерея',
          'Link': 'Посилання',
          'Please first select some text to transform into a link.':
              'Виділіть текст для створення посилання.',
        },
      };

  String get i18n => localize(this, _t);
}
