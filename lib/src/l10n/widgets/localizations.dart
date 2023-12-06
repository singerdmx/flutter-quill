import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../extensions/quill_configurations_ext.dart';
import '../extensions/localizations.dart';

class FlutterQuillLocalizationsWidget extends StatelessWidget {
  const FlutterQuillLocalizationsWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = FlutterQuillLocalizations.of(context);
    if (loc != null) {
      return child;
    }
    return Localizations(
      locale: context.quillSharedConfigurations?.locale ??
          Localizations.localeOf(context),
      delegates: FlutterQuillLocalizations.localizationsDelegates,
      child: child,
    );
  }
}
