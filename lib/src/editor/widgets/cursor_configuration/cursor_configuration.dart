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
    required this.paragraphPlaceholderText,
    required this.style,
    required this.show,
  });

  factory CursorPlaceholderConfig.basic({TextStyle? style}) {
    return CursorPlaceholderConfig(
      paragraphPlaceholderText: 'Enter text...',
      style: style ?? _defaultPlaceholderStyle,
      show: true,
    );
  }

  factory CursorPlaceholderConfig.noPlaceholder() {
    return const CursorPlaceholderConfig(
      paragraphPlaceholderText: '',
      style: TextStyle(),
      show: false,
    );
  }

  /// The text that will be showed at the right
  /// or left of the cursor
  final String paragraphPlaceholderText;

  /// The style of the placeholder
  final TextStyle style;

  /// Decides if the placeholder should be showed
  final bool show;

  @override
  int get hashCode =>
      paragraphPlaceholderText.hashCode ^ style.hashCode ^ show.hashCode;

  @override
  bool operator ==(covariant CursorPlaceholderConfig other) {
    if (identical(this, other)) return true;
    return other.show == show &&
        other.paragraphPlaceholderText == paragraphPlaceholderText &&
        other.style == style;
  }
}
