import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../../flutter_quill.dart';

export './editor/configurations.dart';
export './shared_configurations.dart';
export './toolbar/configurations.dart';

@immutable
class QuillConfigurations extends Equatable {
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

  /// The configurations for the quill editor widget of flutter quill
  final QuillEditorConfigurations editorConfigurations;

  /// The configurations for the toolbar widget of flutter quill
  final QuillToolbarConfigurations toolbarConfigurations;

  /// The shared configurations between [QuillEditorConfigurations] and
  /// [QuillToolbarConfigurations] so we don't duplicate things
  final QuillSharedConfigurations sharedConfigurations;

  @override
  List<Object?> get props => [
        editorConfigurations,
        toolbarConfigurations,
        sharedConfigurations,
      ];
}
