import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// This class contains all necessary configurations
/// to show the wanted placeholder at the level of the cursor
///
/// You can see this as some Rich Text Editors can contains a feature
/// where if the line is empty and not contains any block style (like
/// header, align, codeblock, etc), then will show a text
/// like (assume that "|" is the cursor): "| start writing"

const TextStyle _defaultPlaceholderStyle =
    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);

@immutable
class CursorParagrahPlaceholderConfiguration extends Equatable {
  const CursorParagrahPlaceholderConfiguration({
    required this.paragraphPlaceholderText,
    required this.style,
    required this.show,
  });

  factory CursorParagrahPlaceholderConfiguration.withPlaceholder(
      {TextStyle? style}) {
    return CursorParagrahPlaceholderConfiguration(
      paragraphPlaceholderText: 'Enter text...',
      style: style ?? _defaultPlaceholderStyle,
      show: true,
    );
  }

  factory CursorParagrahPlaceholderConfiguration.noPlaceholder() {
    return const CursorParagrahPlaceholderConfiguration(
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
  List<Object?> get props => [paragraphPlaceholderText, style, show];
}
