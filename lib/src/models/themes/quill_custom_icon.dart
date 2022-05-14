import 'package:flutter/material.dart';

class QuillCustomIcon {
  const QuillCustomIcon({this.icon, this.onTap});

  ///The icon widget
  final IconData? icon;

  ///The function when the icon is tapped
  final VoidCallback? onTap;
}
