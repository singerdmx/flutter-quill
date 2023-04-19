import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuillDialogTheme with Diagnosticable {
  const QuillDialogTheme({
    this.labelTextStyle,
    this.inputTextStyle,
    this.dialogBackgroundColor,
    this.shape,
  });

  ///The text style to use for the label shown in the link-input dialog
  final TextStyle? labelTextStyle;

  ///The text style to use for the input text shown in the link-input dialog
  final TextStyle? inputTextStyle;

  ///The background color for the Quill dialog
  final Color? dialogBackgroundColor;

  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 4.0
  final ShapeBorder? shape;

  QuillDialogTheme copyWith({
    TextStyle? labelTextStyle,
    TextStyle? inputTextStyle,
    Color? dialogBackgroundColor,
    ShapeBorder? shape,
  }) {
    return QuillDialogTheme(
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      dialogBackgroundColor:
          dialogBackgroundColor ?? this.dialogBackgroundColor,
      shape: shape ?? this.shape,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is QuillDialogTheme &&
        other.labelTextStyle == labelTextStyle &&
        other.inputTextStyle == inputTextStyle &&
        other.dialogBackgroundColor == dialogBackgroundColor &&
        other.shape == shape;
  }

  @override
  int get hashCode => Object.hash(
        labelTextStyle,
        inputTextStyle,
        dialogBackgroundColor,
        shape,
      );
}
