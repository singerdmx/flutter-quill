import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show Color, Colors, Locale;

import '../../../flutter_quill.dart';

/// The configurations for the toolbar widget of flutter quill
@immutable
class QuillToolbarConfigurations {
  const QuillToolbarConfigurations();
}

/// The configurations for the quill editor widget of flutter quill
@immutable
class QuillEditorConfigurations {
  const QuillEditorConfigurations();
}

/// The shared configurations between [QuillEditorConfigurations] and
/// [QuillToolbarConfigurations] so we don't duplicate things
class QuillSharedConfigurations {
  const QuillSharedConfigurations({
    this.dialogBarrierColor = Colors.black54,
    this.locale,
  });

  // This is just example or showcase of this major update to make the library
  // more maintanable, flexible, and customizable
  /// The barrier color of the shown dialogs
  final Color dialogBarrierColor;

  /// The locale to use for the editor and toolbar, defaults to system locale
  /// More https://github.com/singerdmx/flutter-quill#translation
  final Locale? locale;
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
