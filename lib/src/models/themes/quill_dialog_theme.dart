import 'package:flutter/material.dart';

class QuillDialogTheme {
  QuillDialogTheme(
      {this.labelTextStyle, this.inputTextStyle, this.dialogBackgroundColor});

  ///The text style to use for the label shown in the link-input dialog
  final TextStyle? labelTextStyle;

  ///The text style to use for the input text shown in the link-input dialog
  final TextStyle? inputTextStyle;

  ///The background color for the [LinkDialog()]
  final Color? dialogBackgroundColor;
}
