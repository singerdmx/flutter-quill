import 'package:flutter/widgets.dart' show BuildContext;

import '../generated/quill_localizations.dart' as generated;

typedef FlutterQuillLocalizations = generated.FlutterQuillLocalizations;

class MissingFlutterQuillLocalizationException extends UnimplementedError {
  MissingFlutterQuillLocalizationException();
  @override
  String? get message =>
      'FlutterQuillLocalizations instance is required and could not found. '
      'Ensure that you are wrapping the current widget with '
      'FlutterQuillLocalizationsWidget or add '
      'FlutterQuillLocalizations.delegate to the localizationsDelegates '
      'in your App widget (e.,g WidgetsApp, MaterialApp). If you believe this is a bug, consider reporting it.';
}

extension LocalizationsExt on BuildContext {
  /// Require the [FlutterQuillLocalizations] instance
  ///
  /// `loc` is short for `localizations`
  FlutterQuillLocalizations get loc {
    return FlutterQuillLocalizations.of(this) ??
        (throw MissingFlutterQuillLocalizationException());
  }
}
