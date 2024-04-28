import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';

/// The [T] is the options for the button
/// The [E] is the extra options for the button
abstract class QuillToolbarBaseValueButton<
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends StatefulWidget {
  const QuillToolbarBaseValueButton(
      {required this.controller, required this.options, super.key});

  final T options;

  final QuillController controller;
}

/// The [W] is the widget that creates this State
/// The [V] is the type of the currentValue
abstract class QuillToolbarBaseValueButtonState<
    W extends QuillToolbarBaseValueButton<T, E>,
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions,
    V> extends State<W> {
  T get options => widget.options;

  QuillController get controller => widget.controller;

  V? _currentValue;
  V get currentValue => _currentValue!;
  set currentValue(V value) => _currentValue = value;

  /// Callback to query the widget's state for the value to be assigned to currentState
  V get currentStateValue;

  @override
  void initState() {
    super.initState();
    controller.addListener(didChangeEditingValue);
    addExtraListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentValue = currentStateValue;
  }

  void didChangeEditingValue() {
    setState(() => currentValue = currentStateValue);
  }

  @override
  void dispose() {
    controller.removeListener(didChangeEditingValue);
    removeExtraListener(widget);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(didChangeEditingValue);
      removeExtraListener(oldWidget);
      controller.addListener(didChangeEditingValue);
      addExtraListener();
      currentValue = currentStateValue;
    }
  }

  /// Extra listeners allow a subclass to listen to an external event that can affect its currentValue
  void addExtraListener() {}
  void removeExtraListener(covariant W oldWidget) {}

  String get defaultTooltip;

  String get tooltip {
    return options.tooltip ??
        context.quillToolbarBaseButtonOptions?.tooltip ??
        defaultTooltip;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions?.iconSize;
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

typedef QuillToolbarToggleStyleBaseButton = QuillToolbarBaseValueButton<
    QuillToolbarToggleStyleButtonOptions,
    QuillToolbarToggleStyleButtonExtraOptions>;

typedef QuillToolbarToggleStyleBaseButtonState<
        W extends QuillToolbarToggleStyleBaseButton>
    = QuillToolbarBaseValueButtonState<W, QuillToolbarToggleStyleButtonOptions,
        QuillToolbarToggleStyleButtonExtraOptions, bool>;
