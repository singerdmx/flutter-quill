import 'package:flutter/material.dart';
import 'default_styles.dart';

class QuillStyles extends InheritedWidget {
  const QuillStyles({
    required this.data,
    required super.child,
    super.key,
  });

  final DefaultStyles data;

  @override
  bool updateShouldNotify(QuillStyles oldWidget) {
    return data != oldWidget.data;
  }

  static DefaultStyles? getStyles(BuildContext context, bool nullOk) {
    final widget = context.dependOnInheritedWidgetOfExactType<QuillStyles>();
    if (widget == null && nullOk) {
      return null;
    }
    assert(widget != null);
    return widget!.data;
  }
}
