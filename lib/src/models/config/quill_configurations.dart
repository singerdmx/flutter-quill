import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../../../flutter_quill.dart';

export './editor/configurations.dart';
export 'quill_shared_configurations.dart';
export 'toolbar/toolbar_configurations.dart';

@immutable
class QuillConfigurations extends Equatable {
  const QuillConfigurations({
    required this.controller,
    this.sharedConfigurations = const QuillSharedConfigurations(),
  });

  /// Controller object which establishes a link between a rich text document
  /// and this editor.
  ///
  /// The controller is shared between [QuillEditorConfigurations] and
  /// [QuillToolbarConfigurations] but to simplify things we will defined it
  /// here, it should not be null
  final QuillController controller;

  /// The shared configurations between [QuillEditorConfigurations] and
  /// [QuillToolbarConfigurations] so we don't duplicate things
  final QuillSharedConfigurations sharedConfigurations;

  @override
  List<Object?> get props => [
        sharedConfigurations,
      ];
}
