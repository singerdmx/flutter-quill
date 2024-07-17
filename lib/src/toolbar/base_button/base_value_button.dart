import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

/// The [T] is the options for the button
/// The [E] is the extra options for the button
abstract class QuillToolbarBaseButton<
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends StatefulWidget {
  const QuillToolbarBaseButton(
      {required this.controller, required this.options, super.key});

  final T options;

  final QuillController controller;
}

/// The [W] is the widget that creates this State
abstract class QuillToolbarCommonButtonState<
    W extends QuillToolbarBaseButton<T, E>,
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends State<W> {
  T get options => widget.options;

  QuillController get controller => widget.controller;

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions =>
      context.quillToolbarBaseButtonOptions;

  String get defaultTooltip;

  String get tooltip =>
      options.tooltip ?? baseButtonExtraOptions?.tooltip ?? defaultTooltip;

  IconData get defaultIconData;

  IconData get iconData =>
      options.iconData ??
      context.quillToolbarBaseButtonOptions?.iconData ??
      defaultIconData;

  double get iconSize =>
      options.iconSize ?? baseButtonExtraOptions?.iconSize ?? kDefaultIconSize;

  double get iconButtonFactor =>
      options.iconButtonFactor ??
      baseButtonExtraOptions?.iconButtonFactor ??
      kDefaultIconButtonFactor;

  QuillIconTheme? get iconTheme =>
      options.iconTheme ?? baseButtonExtraOptions?.iconTheme;

  VoidCallback? get afterButtonPressed =>
      options.afterButtonPressed ??
      baseButtonExtraOptions?.afterButtonPressed ??
      () => controller.editorFocusNode?.requestFocus();
}

/// The [W] is the widget that creates this State
/// The [V] is the type of the currentValue
abstract class QuillToolbarBaseButtonState<
    W extends QuillToolbarBaseButton<T, E>,
    T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions,
    V> extends QuillToolbarCommonButtonState<W, T, E> {
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
    if (!mounted) return;
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
}

typedef QuillToolbarToggleStyleBaseButton = QuillToolbarBaseButton<
    QuillToolbarToggleStyleButtonOptions,
    QuillToolbarToggleStyleButtonExtraOptions>;

typedef QuillToolbarToggleStyleBaseButtonState<
        W extends QuillToolbarToggleStyleBaseButton>
    = QuillToolbarBaseButtonState<W, QuillToolbarToggleStyleButtonOptions,
        QuillToolbarToggleStyleButtonExtraOptions, bool>;
