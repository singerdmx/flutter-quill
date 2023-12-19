import 'package:flutter/widgets.dart' show BuildContext;

import '../../flutter_quill.dart';

extension QuillControllerExt on BuildContext {
  /// return nullable [QuillController]
  QuillController? get quilController {
    return quillSimpleToolbarConfigurations?.controller ??
        quillEditorConfigurations?.controller;
  }

  /// return [QuillController] as not null
  QuillController get requireQuillController {
    return quillSimpleToolbarConfigurations?.controller ??
        quillEditorConfigurations?.controller ??
        (throw ArgumentError(
            'The quill provider is required, you must only call requireQuillController inside the QuillToolbar and QuillEditor'));
  }
}

extension QuillSharedExt on BuildContext {
  /// return nullable [QuillSharedConfigurations]
  QuillSharedConfigurations? get quillSharedConfigurations {
    return quillSimpleToolbarConfigurations?.sharedConfigurations ??
        quillEditorConfigurations?.sharedConfigurations;
  }
}

extension QuillEditorExt on BuildContext {
  /// return [QuillEditorConfigurations] as not null
  QuillEditorConfigurations get requireQuillEditorConfigurations {
    return QuillEditorProvider.of(this).editorConfigurations;
  }

  /// return nullable [QuillEditorConfigurations]
  QuillEditorConfigurations? get quillEditorConfigurations {
    return QuillEditorProvider.maybeOf(this)?.editorConfigurations;
  }

  /// return nullable [QuillToolbarBaseButtonOptions]. Since the quill
  /// quill editor block options is in the [QuillEditorProvider] then we need to
  /// get the provider widget first and then we will return block options
  /// throw exception if [QuillEditorProvider] is not in the widget tree
  QuillEditorElementOptions? get quillEditorElementOptions {
    return quillEditorConfigurations?.elementOptions;
  }

  /// return [QuillToolbarBaseButtonOptions] as not null. Since the quill
  /// quill editor block options is in the [QuillEditorProvider] then we need to
  /// get the provider widget first and then we will return block options
  /// don't throw exception if [QuillEditorProvider] is not in the widget tree
  QuillEditorElementOptions get requireQuillEditorElementOptions {
    return requireQuillEditorConfigurations.elementOptions;
  }
}

extension QuillSimpleToolbarExt on BuildContext {
  /// return [QuillSimpleToolbarConfigurations] as not null
  QuillSimpleToolbarConfigurations get requireQuillSimpleToolbarConfigurations {
    return QuillSimpleToolbarProvider.of(this).toolbarConfigurations;
  }

  /// return nullable [QuillSimpleToolbarConfigurations]
  QuillSimpleToolbarConfigurations? get quillSimpleToolbarConfigurations {
    return QuillSimpleToolbarProvider.maybeOf(this)?.toolbarConfigurations;
  }

  /// return nullable [QuillToolbarBaseButtonOptions].
  QuillToolbarBaseButtonOptions? get quillToolbarBaseButtonOptions {
    return quillSimpleToolbarConfigurations?.buttonOptions.base;
  }
}

extension QuillToolbarExt on BuildContext {
  /// return [QuillToolbarConfigurations] as not null
  QuillToolbarConfigurations get requireQuillToolbarConfigurations {
    return QuillToolbarProvider.of(this).toolbarConfigurations;
  }

  /// return nullable [QuillToolbarConfigurations].
  QuillToolbarConfigurations? get quillToolbarConfigurations {
    return QuillToolbarProvider.maybeOf(this)?.toolbarConfigurations;
  }
}
