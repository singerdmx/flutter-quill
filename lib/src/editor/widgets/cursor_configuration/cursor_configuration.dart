import 'package:flutter/material.dart';

const TextStyle _defaultPlaceholderStyle =
    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

/// Configuration for displaying a placeholder near the cursor in a rich text editor.
///
/// The `CursorPlaceholderConfig` defines the appearance, position, and behavior 
/// of a placeholder that is shown when a line is empty and the cursor is present.
/// This feature mimics behavior in some rich text editors where placeholder text 
/// (e.g., "Start writing...") appears as a prompt when no content is entered.
@immutable
class CursorPlaceholderConfig {
  const CursorPlaceholderConfig({
    required this.text,
    required this.textStyle,
    required this.show,
    required this.offset,
  });

  /// Creates a basic configuration for a cursor placeholder with default text and style.
  ///
  /// Parameters:
  /// - [textStyle]: An optional custom style for the placeholder text.
  ///   Defaults to [_defaultPlaceholderStyle] if not provided.
  factory CursorPlaceholderConfig.basic({TextStyle? textStyle}) {
    return CursorPlaceholderConfig(
      text: 'Enter text...',
      textStyle: textStyle ?? _defaultPlaceholderStyle,
      show: true,
      offset: const Offset(3.5, 5),
    );
  }

  factory CursorPlaceholderConfig.noPlaceholder() {
    return const CursorPlaceholderConfig(
      text: '',
      textStyle: TextStyle(),
      show: false,
      offset: null,
    );
  }

  /// this text that will be showed at the right
  /// or left of the cursor
  final String text;

  /// this is the text style of the placeholder
  final TextStyle textStyle;

  /// Decides if the placeholder should be showed
  final bool show;

  /// The offset position where the placeholder text will be rendered.
  final Offset? offset;

  @override
  int get hashCode =>
      text.hashCode ^ textStyle.hashCode ^ show.hashCode ^ offset.hashCode;

  @override
  bool operator ==(covariant CursorPlaceholderConfig other) {
    if (identical(this, other)) return true;
    return other.show == show &&
        other.text == text &&
        other.textStyle == textStyle &&
        other.offset == offset;
  }
}
