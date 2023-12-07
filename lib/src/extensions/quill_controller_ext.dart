import 'package:flutter/widgets.dart' show BuildContext;

import '../../flutter_quill.dart' show QuillController;
import 'quill_configurations_ext.dart';

extension QuillControllerNullableExt on QuillController? {
  /// Simple logic to use the current passed controller if not null
  /// if null then we will have to use the default one
  /// using the [context]
  QuillController notNull(BuildContext context) {
    final controller = this;
    if (controller != null) {
      return controller;
    }
    return context.requireQuillController;
  }
}
