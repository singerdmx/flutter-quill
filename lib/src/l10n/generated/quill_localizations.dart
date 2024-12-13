import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'quill_localizations_ar.dart';
import 'quill_localizations_bg.dart';
import 'quill_localizations_bn.dart';
import 'quill_localizations_ca.dart';
import 'quill_localizations_cs.dart';
import 'quill_localizations_da.dart';
import 'quill_localizations_de.dart';
import 'quill_localizations_el.dart';
import 'quill_localizations_en.dart';
import 'quill_localizations_es.dart';
import 'quill_localizations_fa.dart';
import 'quill_localizations_fr.dart';
import 'quill_localizations_he.dart';
import 'quill_localizations_hi.dart';
import 'quill_localizations_hu.dart';
import 'quill_localizations_id.dart';
import 'quill_localizations_it.dart';
import 'quill_localizations_ja.dart';
import 'quill_localizations_km.dart';
import 'quill_localizations_ko.dart';
import 'quill_localizations_ku.dart';
import 'quill_localizations_ms.dart';
import 'quill_localizations_ne.dart';
import 'quill_localizations_nl.dart';
import 'quill_localizations_no.dart';
import 'quill_localizations_pl.dart';
import 'quill_localizations_pt.dart';
import 'quill_localizations_ro.dart';
import 'quill_localizations_ru.dart';
import 'quill_localizations_sk.dart';
import 'quill_localizations_sr.dart';
import 'quill_localizations_sv.dart';
import 'quill_localizations_sw.dart';
import 'quill_localizations_th.dart';
import 'quill_localizations_tk.dart';
import 'quill_localizations_tr.dart';
import 'quill_localizations_uk.dart';
import 'quill_localizations_ur.dart';
import 'quill_localizations_vi.dart';
import 'quill_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterQuillLocalizations
/// returned by `FlutterQuillLocalizations.of(context)`.
///
/// Applications need to include `FlutterQuillLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/quill_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
///   supportedLocales: FlutterQuillLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FlutterQuillLocalizations.supportedLocales
/// property.
abstract class FlutterQuillLocalizations {
  FlutterQuillLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterQuillLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterQuillLocalizations>(
        context, FlutterQuillLocalizations);
  }

  static const LocalizationsDelegate<FlutterQuillLocalizations> delegate =
      _FlutterQuillLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('bn'),
    Locale('ca'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('ku'),
    Locale('ku', 'CKB'),
    Locale('ms'),
    Locale('ne'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ro'),
    Locale('ro', 'RO'),
    Locale('ru'),
    Locale('sk'),
    Locale('sr'),
    Locale('sv'),
    Locale('sw'),
    Locale('th'),
    Locale('tk'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'HK')
  ];

  /// No description provided for @pasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get pasteLink;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @zoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoom;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @resize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get resize;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @huge.
  ///
  /// In en, this message translates to:
  /// **'Huge'**
  String get huge;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font family'**
  String get fontFamily;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @subscript.
  ///
  /// In en, this message translates to:
  /// **'Subscript'**
  String get subscript;

  /// No description provided for @superscript.
  ///
  /// In en, this message translates to:
  /// **'Superscript'**
  String get superscript;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @strikeThrough.
  ///
  /// In en, this message translates to:
  /// **'Strike through'**
  String get strikeThrough;

  /// No description provided for @inlineCode.
  ///
  /// In en, this message translates to:
  /// **'Inline code'**
  String get inlineCode;

  /// No description provided for @fontColor.
  ///
  /// In en, this message translates to:
  /// **'Font color'**
  String get fontColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColor;

  /// No description provided for @clearFormat.
  ///
  /// In en, this message translates to:
  /// **'Clear format'**
  String get clearFormat;

  /// No description provided for @alignLeft.
  ///
  /// In en, this message translates to:
  /// **'Align left'**
  String get alignLeft;

  /// No description provided for @alignCenter.
  ///
  /// In en, this message translates to:
  /// **'Align center'**
  String get alignCenter;

  /// No description provided for @alignRight.
  ///
  /// In en, this message translates to:
  /// **'Align right'**
  String get alignRight;

  /// Justify the text over the full window width
  ///
  /// In en, this message translates to:
  /// **'Align justify'**
  String get alignJustify;

  /// No description provided for @justifyWinWidth.
  ///
  /// In en, this message translates to:
  /// **'Justify win width'**
  String get justifyWinWidth;

  /// No description provided for @textDirection.
  ///
  /// In en, this message translates to:
  /// **'Text direction'**
  String get textDirection;

  /// No description provided for @headerStyle.
  ///
  /// In en, this message translates to:
  /// **'Header style'**
  String get headerStyle;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @heading1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get heading1;

  /// No description provided for @heading2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get heading2;

  /// No description provided for @heading3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get heading3;

  /// No description provided for @heading4.
  ///
  /// In en, this message translates to:
  /// **'Heading 4'**
  String get heading4;

  /// No description provided for @heading5.
  ///
  /// In en, this message translates to:
  /// **'Heading 5'**
  String get heading5;

  /// No description provided for @heading6.
  ///
  /// In en, this message translates to:
  /// **'Heading 6'**
  String get heading6;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get numberedList;

  /// No description provided for @bulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get bulletList;

  /// No description provided for @checkedList.
  ///
  /// In en, this message translates to:
  /// **'Checked list'**
  String get checkedList;

  /// No description provided for @codeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code block'**
  String get codeBlock;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @increaseIndent.
  ///
  /// In en, this message translates to:
  /// **'Increase indent'**
  String get increaseIndent;

  /// No description provided for @decreaseIndent.
  ///
  /// In en, this message translates to:
  /// **'Decrease indent'**
  String get decreaseIndent;

  /// No description provided for @insertURL.
  ///
  /// In en, this message translates to:
  /// **'Insert URL'**
  String get insertURL;

  /// No description provided for @visitLink.
  ///
  /// In en, this message translates to:
  /// **'Visit link'**
  String get visitLink;

  /// No description provided for @enterLink.
  ///
  /// In en, this message translates to:
  /// **'Enter link'**
  String get enterLink;

  /// No description provided for @enterMedia.
  ///
  /// In en, this message translates to:
  /// **'Enter media'**
  String get enterMedia;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @hex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get hex;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @lineheight.
  ///
  /// In en, this message translates to:
  /// **'Line height'**
  String get lineheight;

  /// No description provided for @findText.
  ///
  /// In en, this message translates to:
  /// **'Find text'**
  String get findText;

  /// No description provided for @moveToPreviousOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Move to previous occurrence'**
  String get moveToPreviousOccurrence;

  /// No description provided for @moveToNextOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Move to next occurrence'**
  String get moveToNextOccurrence;

  /// No description provided for @savedUsingTheNetwork.
  ///
  /// In en, this message translates to:
  /// **'Saved using the network'**
  String get savedUsingTheNetwork;

  /// No description provided for @savedUsingLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'Saved using the local storage'**
  String get savedUsingLocalStorage;

  /// A message with a single parameter
  ///
  /// In en, this message translates to:
  /// **'The image has been saved at: {imagePath}'**
  String theImageHasBeenSavedAt(String imagePath);

  /// No description provided for @errorWhileSavingImage.
  ///
  /// In en, this message translates to:
  /// **'Error while saving image'**
  String get errorWhileSavingImage;

  /// No description provided for @pleaseEnterTextForYourLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter a text for your link (e.g., \'Learn more\')'**
  String get pleaseEnterTextForYourLink;

  /// No description provided for @pleaseEnterTheLinkURL.
  ///
  /// In en, this message translates to:
  /// **'Please enter the link URL (e.g., \'https://example.com\')'**
  String get pleaseEnterTheLinkURL;

  /// No description provided for @pleaseEnterAValidImageURL.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid image URL'**
  String get pleaseEnterAValidImageURL;

  /// No description provided for @pleaseEnterAValidVideoURL.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid video url'**
  String get pleaseEnterAValidVideoURL;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @caseSensitivityAndWholeWordSearch.
  ///
  /// In en, this message translates to:
  /// **'Case sensitivity and whole word search'**
  String get caseSensitivityAndWholeWordSearch;

  /// No description provided for @caseSensitive.
  ///
  /// In en, this message translates to:
  /// **'Case sensitive'**
  String get caseSensitive;

  /// No description provided for @wholeWord.
  ///
  /// In en, this message translates to:
  /// **'Whole word'**
  String get wholeWord;

  /// No description provided for @insertImage.
  ///
  /// In en, this message translates to:
  /// **'Insert image'**
  String get insertImage;

  /// No description provided for @pickAPhotoFromYourGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo from your gallery'**
  String get pickAPhotoFromYourGallery;

  /// No description provided for @takeAPhotoUsingYourCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo using your camera'**
  String get takeAPhotoUsingYourCamera;

  /// No description provided for @pasteAPhotoUsingALink.
  ///
  /// In en, this message translates to:
  /// **'Paste a photo using a link'**
  String get pasteAPhotoUsingALink;

  /// No description provided for @pickAVideoFromYourGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick a video from your gallery'**
  String get pickAVideoFromYourGallery;

  /// No description provided for @recordAVideoUsingYourCamera.
  ///
  /// In en, this message translates to:
  /// **'Record a video using your camera'**
  String get recordAVideoUsingYourCamera;

  /// No description provided for @pasteAVideoUsingALink.
  ///
  /// In en, this message translates to:
  /// **'Paste a video using a link'**
  String get pasteAVideoUsingALink;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get searchSettings;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @insertTable.
  ///
  /// In en, this message translates to:
  /// **'Insert table'**
  String get insertTable;

  /// No description provided for @insertVideo.
  ///
  /// In en, this message translates to:
  /// **'Insert video'**
  String get insertVideo;

  /// A generic error message shown when an image cannot be saved due to an unknown issue
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while saving the image. Please try again.'**
  String get errorUnexpectedSavingImage;

  /// Message shown when an image is successfully saved to the system gallery
  ///
  /// In en, this message translates to:
  /// **'Image saved to your gallery.'**
  String get successImageSavedGallery;

  /// Message shown on desktop when an image is successfully saved. The user is prompted to open the file location
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully.'**
  String get successImageSaved;

  /// Message shown on web when an image is successfully downloaded
  ///
  /// In en, this message translates to:
  /// **'Image downloaded successfully.'**
  String get successImageDownloaded;

  /// Label for the button that opens the system gallery
  ///
  /// In en, this message translates to:
  /// **'Open Gallery'**
  String get openGallery;

  /// Label for the button that opens the file explorer to the file's location
  ///
  /// In en, this message translates to:
  /// **'Open File Location'**
  String get openFileLocation;

  /// Label for the button that opens the file
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// Message shown when the app is unable to save an image because a required permission was denied or skipped
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the image due to missing permission'**
  String get saveImagePermissionDenied;
}

class _FlutterQuillLocalizationsDelegate
    extends LocalizationsDelegate<FlutterQuillLocalizations> {
  const _FlutterQuillLocalizationsDelegate();

  @override
  Future<FlutterQuillLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterQuillLocalizations>(
        lookupFlutterQuillLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'bg',
        'bn',
        'ca',
        'cs',
        'da',
        'de',
        'el',
        'en',
        'es',
        'fa',
        'fr',
        'he',
        'hi',
        'hu',
        'id',
        'it',
        'ja',
        'km',
        'ko',
        'ku',
        'ms',
        'ne',
        'nl',
        'no',
        'pl',
        'pt',
        'ro',
        'ru',
        'sk',
        'sr',
        'sv',
        'sw',
        'th',
        'tk',
        'tr',
        'uk',
        'ur',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_FlutterQuillLocalizationsDelegate old) => false;
}

FlutterQuillLocalizations lookupFlutterQuillLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return FlutterQuillLocalizationsEnUs();
        }
        break;
      }
    case 'ku':
      {
        switch (locale.countryCode) {
          case 'CKB':
            return FlutterQuillLocalizationsKuCkb();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return FlutterQuillLocalizationsPtBr();
        }
        break;
      }
    case 'ro':
      {
        switch (locale.countryCode) {
          case 'RO':
            return FlutterQuillLocalizationsRoRo();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return FlutterQuillLocalizationsZhCn();
          case 'HK':
            return FlutterQuillLocalizationsZhHk();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return FlutterQuillLocalizationsAr();
    case 'bg':
      return FlutterQuillLocalizationsBg();
    case 'bn':
      return FlutterQuillLocalizationsBn();
    case 'ca':
      return FlutterQuillLocalizationsCa();
    case 'cs':
      return FlutterQuillLocalizationsCs();
    case 'da':
      return FlutterQuillLocalizationsDa();
    case 'de':
      return FlutterQuillLocalizationsDe();
    case 'el':
      return FlutterQuillLocalizationsEl();
    case 'en':
      return FlutterQuillLocalizationsEn();
    case 'es':
      return FlutterQuillLocalizationsEs();
    case 'fa':
      return FlutterQuillLocalizationsFa();
    case 'fr':
      return FlutterQuillLocalizationsFr();
    case 'he':
      return FlutterQuillLocalizationsHe();
    case 'hi':
      return FlutterQuillLocalizationsHi();
    case 'hu':
      return FlutterQuillLocalizationsHu();
    case 'id':
      return FlutterQuillLocalizationsId();
    case 'it':
      return FlutterQuillLocalizationsIt();
    case 'ja':
      return FlutterQuillLocalizationsJa();
    case 'km':
      return FlutterQuillLocalizationsKm();
    case 'ko':
      return FlutterQuillLocalizationsKo();
    case 'ku':
      return FlutterQuillLocalizationsKu();
    case 'ms':
      return FlutterQuillLocalizationsMs();
    case 'ne':
      return FlutterQuillLocalizationsNe();
    case 'nl':
      return FlutterQuillLocalizationsNl();
    case 'no':
      return FlutterQuillLocalizationsNo();
    case 'pl':
      return FlutterQuillLocalizationsPl();
    case 'pt':
      return FlutterQuillLocalizationsPt();
    case 'ro':
      return FlutterQuillLocalizationsRo();
    case 'ru':
      return FlutterQuillLocalizationsRu();
    case 'sk':
      return FlutterQuillLocalizationsSk();
    case 'sr':
      return FlutterQuillLocalizationsSr();
    case 'sv':
      return FlutterQuillLocalizationsSv();
    case 'sw':
      return FlutterQuillLocalizationsSw();
    case 'th':
      return FlutterQuillLocalizationsTh();
    case 'tk':
      return FlutterQuillLocalizationsTk();
    case 'tr':
      return FlutterQuillLocalizationsTr();
    case 'uk':
      return FlutterQuillLocalizationsUk();
    case 'ur':
      return FlutterQuillLocalizationsUr();
    case 'vi':
      return FlutterQuillLocalizationsVi();
    case 'zh':
      return FlutterQuillLocalizationsZh();
  }

  throw FlutterError(
      'FlutterQuillLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
