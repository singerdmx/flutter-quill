import 'package:flutter/widgets.dart' show BuildContext;

import '../editor/provider.dart';
import '../toolbar/simple_toolbar_provider.dart';
import 'config/quill_shared_configurations.dart';

extension QuillSharedExt on BuildContext {
  /// return nullable [QuillSharedConfigurations]
  QuillSharedConfigurations? get quillSharedConfigurations {
    return quillSimpleToolbarConfigurations?.sharedConfigurations ??
        quillEditorConfigurations?.sharedConfigurations;
  }
}
