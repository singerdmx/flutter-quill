import 'package:flutter/widgets.dart' show BuildContext;

import '../editor/provider.dart';
import '../toolbar/simple_toolbar_provider.dart';
import 'quill_controller.dart';

extension QuillControllerExt on BuildContext {
  QuillController? get quilController {
    // ignore: deprecated_member_use_from_same_package
    return quillSimpleToolbarConfigurations?.controller ??
        // ignore: deprecated_member_use_from_same_package
        quillEditorConfigurations?.controller;
  }

  QuillController get requireQuillController {
    // ignore: deprecated_member_use_from_same_package
    return quillSimpleToolbarConfigurations?.controller ??
        // ignore: deprecated_member_use_from_same_package
        quillEditorConfigurations?.controller ??
        (throw ArgumentError(
            'The quill provider is required, you must only call requireQuillController inside the QuillToolbar and QuillEditor'));
  }
}
