import 'package:flutter/widgets.dart' show BuildContext;

import '../gen/flutter_gen/gen_l10n/flutter_quill_localizations.dart'
    as generated;

typedef FlutterQuillLocalizations = generated.AppLocalizations;

extension LocalizationsExt on BuildContext {
  FlutterQuillLocalizations get localizations {
    return FlutterQuillLocalizations.of(this) ??
        (throw UnsupportedError(
          "The instance of FlutterQuillLocalizations.of(context) is null and it's required",
        ));
  }
}
