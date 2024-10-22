import 'package:flutter/widgets.dart' show BuildContext;

import '../generated/quill_localizations.dart';

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
  /// Require the [FlutterQuillLocalizations] instance.
  ///
  /// `loc` is short for `localizations`
  FlutterQuillLocalizations get loc {
    return FlutterQuillLocalizations.of(this) ??
        (throw MissingFlutterQuillLocalizationException());
  }
}
