import 'package:flutter/widgets.dart' show BuildContext;

import '../generated/quill_localizations.dart' as generated;

typedef FlutterQuillLocalizations = generated.FlutterQuillLocalizations;

extension LocalizationsExt on BuildContext {
  /// Require the [FlutterQuillLocalizations] instance
  ///
  /// `loc` is short for `localizations`
  FlutterQuillLocalizations get loc {
    return FlutterQuillLocalizations.of(this) ??
        (throw UnimplementedError(
          "The instance of FlutterQuillLocalizations.of(context) is null and it's"
          ' required, please make sure you wrapping the current widget with '
          'FlutterQuillLocalizationsWidget or add '
          'FlutterQuillLocalizations.delegate to the localizationsDelegates '
          'in your App widget, please consider report this in GitHub as a bug',
        ));
  }
}
