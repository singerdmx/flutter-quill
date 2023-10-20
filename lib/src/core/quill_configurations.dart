import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Color, Colors;

import '../../flutter_quill.dart';

// I will start on this in the major-update-2

@immutable
class QuillToolbarConfigurations {
  const QuillToolbarConfigurations();
}

///
@immutable
class QuillEditorConfigurations {
  const QuillEditorConfigurations();
}

/// The shared configurations between [QuillEditorConfigurations] and
/// [QuillToolbarConfigurations] so we don't duplicate things
class QuillSharedConfigurations {
  const QuillSharedConfigurations({
    this.dialogBarrierColor = Colors.black54,
  });

  // This is just example or showcase of this major update to make the library
  // more maintanable, flexible, and customizable
  /// The barrier color of the shown dialogs
  final Color dialogBarrierColor;
}

@immutable
class QuillConfigurations {
  const QuillConfigurations({
    required this.controller,
    this.editorConfigurations = const QuillEditorConfigurations(),
    this.toolbarConfigurations = const QuillToolbarConfigurations(),
    this.sharedConfigurations = const QuillSharedConfigurations(),
  });

  /// Controller object which establishes a link between a rich text document
  /// and this editor.
  ///
  /// The controller is shared between [QuillEditorConfigurations] and
  /// [QuillToolbarConfigurations] but to simplify things we will defined it
  /// here, it should not be null
  final QuillController controller;

  final QuillEditorConfigurations editorConfigurations;

  final QuillToolbarConfigurations toolbarConfigurations;

  final QuillSharedConfigurations sharedConfigurations;
}
