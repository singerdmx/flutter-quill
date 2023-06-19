import 'package:flutter/material.dart';

class QuillCustomButton {
  const QuillCustomButton({this.icon, this.onTap, this.child});

  ///The icon widget
  final IconData? icon;

  ///The function when the icon is tapped
  final VoidCallback? onTap;

  ///The customButton placeholder
  final Widget? child;
}
