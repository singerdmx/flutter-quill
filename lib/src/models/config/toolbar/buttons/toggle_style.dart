import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show IconData;

import 'base.dart';

@immutable
class QuillToolbarToggleStyleButtonOptions
    extends QuillToolbarBaseButtonOptions {
  const QuillToolbarToggleStyleButtonOptions({
    required this.iconData,
  });

  @override
  final IconData iconData;
}
