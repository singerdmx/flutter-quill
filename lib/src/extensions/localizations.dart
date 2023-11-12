import 'package:flutter/widgets.dart' show BuildContext;

import '../l10n/generated/quill_localizations.dart' as generated;

// import '../gen/flutter_gen/gen_l10n/quill_localizations.dart' as generated;

typedef FlutterQuillLocalizations = generated.FlutterQuillLocalizations;

extension LocalizationsExt on BuildContext {
  generated.FlutterQuillLocalizations get localizations {
    return generated.FlutterQuillLocalizations.of(this) ??
        (throw UnsupportedError(
          "The instance of FlutterQuillLocalizations.of(context) is null and it's required",
        ));
  }
}
