import 'package:flutter/widgets.dart' show BuildContext;

import 'provider.dart';
import 'quill_controller.dart';

// TODO: Remove this file later

@Deprecated('No longer used internally and will be removed in future releases')
extension QuillControllerNullableExt on QuillController? {
  /// Return the controller from the widget tree using [context].
  /// Throw if null.
  @Deprecated(
    'No longer used internally and will be removed in future releases',
  )
  QuillController notNull(BuildContext context) {
    final controller = this;
    if (controller != null) {
      return controller;
    }
    return context.requireQuillController;
  }
}
