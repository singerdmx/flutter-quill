import 'package:flutter/widgets.dart' show BuildContext;

import '../editor/provider.dart';
import '../toolbar/simple_toolbar_provider.dart';
import 'quill_controller.dart';

extension QuillControllerExt on BuildContext {
  QuillController? get quilController {
    return quillSimpleToolbarConfigurations?.controller ??
        quillEditorConfigurations?.controller;
  }

  QuillController get requireQuillController {
    return quillSimpleToolbarConfigurations?.controller ??
        quillEditorConfigurations?.controller ??
        (throw ArgumentError(
            'The quill provider is required, you must only call requireQuillController inside the QuillToolbar and QuillEditor'));
  }
}
