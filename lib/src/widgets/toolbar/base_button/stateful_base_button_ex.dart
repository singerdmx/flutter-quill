import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';

/// The [T] is the options for the button
/// The [E] is the extra options for the button
abstract class QuillToolbarStatefulBaseButton<
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends StatefulWidget {
  const QuillToolbarStatefulBaseButton(
      {required this.controller, required this.options, super.key});

  final T options;

  final QuillController controller;
}

/// The [W] is the widget that creates this State
abstract class QuillToolbarBaseButtonState<
    W extends QuillToolbarStatefulBaseButton<T, E>,
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends State<W> {
  T get options => widget.options;

  QuillController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(didChangeEditingValue);
  }

  void didChangeEditingValue();

  @override
  void dispose() {
    controller.removeListener(didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(didChangeEditingValue);
      controller.addListener(didChangeEditingValue);
    }
  }

  String get defaultTooltip;

  String get tooltip {
    return options.tooltip ??
        context.quillToolbarBaseButtonOptions?.tooltip ??
        defaultTooltip;
  }

  double get iconSize {
    final baseFontSize = context.quillToolbarBaseButtonOptions?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions?.iconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions {
    return context.quillToolbarBaseButtonOptions;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions?.afterButtonPressed;
  }
}
