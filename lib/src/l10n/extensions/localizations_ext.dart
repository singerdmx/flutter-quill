import 'package:flutter/widgets.dart' show BuildContext;

import '../generated/quill_localizations.dart';
import '../generated/quill_localizations_en.dart';

@Deprecated(
  'FlutterQuill now falls back to English strings when the localization '
  'delegate is missing. This exception will be removed in a future release.',
)
class MissingFlutterQuillLocalizationException extends UnimplementedError {
  MissingFlutterQuillLocalizationException();
  @override
  String? get message =>
      '$FlutterQuillLocalizations instance is required and could not found.\n'
      'Add the delegate `FlutterQuillLocalizations.delegate` to your widget app (e.g., MaterialApp) to fix.\n'
      'If the issue continues, consider reporting a bug.\n'
      'See https://github.com/singerdmx/flutter-quill/blob/master/doc/translation.md';
}

extension LocalizationsExt on BuildContext {
  static final FlutterQuillLocalizations _fallbackLocalization =
      FlutterQuillLocalizationsEn();

  /// Retrieve the [FlutterQuillLocalizations] instance, falling back to the
  /// default English messages if no delegate is registered.
  ///
  /// `loc` is short for `localizations`.
  FlutterQuillLocalizations get loc {
    return FlutterQuillLocalizations.of(this) ?? _fallbackLocalization;
  }
}
