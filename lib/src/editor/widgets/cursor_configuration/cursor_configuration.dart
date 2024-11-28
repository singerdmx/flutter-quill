import 'package:flutter/material.dart';

const TextStyle _defaultPlaceholderStyle =
    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

/// This class contains all necessary configurations
/// to show the wanted placeholder at the level of the cursor
///
/// You can see this as some Rich Text Editors can contains a feature
/// where if the line is empty and not contains any block style (like
/// header, align, codeblock, etc), then will show a text
/// like (assume that "|" is the cursor): "| start writing"
@immutable
class CursorPlaceholderConfig {
  const CursorPlaceholderConfig({
    required this.text,
    required this.textStyle,
    required this.show,
    required this.offset,
  });

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

  /// The text that will be showed at the right
  /// or left of the cursor
  final String text;

  /// The textStyle of the placeholder
  final TextStyle textStyle;

  /// Decides if the placeholder should be showed
  final bool show;

  /// Decides the offset where will be painted the text
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
