import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

/// The configurations for the quill editor widget of flutter quill
@immutable
class QuillEditorConfigurations extends Equatable {
  const QuillEditorConfigurations({
    this.placeholder,
    this.readOnly = false,
  });

  /// The text placeholder in the quill editor
  final String? placeholder;

  /// Whether the text can be changed.
  ///
  /// When this is set to `true`, the text cannot be modified
  /// by any shortcut or keyboard operation. The text is still selectable.
  ///
  /// Defaults to `false`. Must not be `null`.
  final bool readOnly;

  @override
  List<Object?> get props => [
        placeholder,
        readOnly,
      ];
}
