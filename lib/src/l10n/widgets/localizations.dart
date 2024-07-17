import 'package:flutter/material.dart';

import '../../editor_toolbar_shared/quill_configurations_ext.dart';
import '../extensions/localizations_ext.dart';

/// A widget that check if [FlutterQuillLocalizations.delegate] is provided
/// in the widgets app (e.g, [MaterialApp] or [WidgetsApp]).
///
/// If not, will provide in the [child] to access it in the widget tree.
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
