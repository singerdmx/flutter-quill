import 'package:flutter/material.dart';

typedef WidgetWrapper = Widget Function(Widget child);

/// Provides utiulity widgets.
abstract class UtilityWidgets {
  /// Conditionally wraps the [child] with [Tooltip] widget if [message]
  /// is not null and not empty.
  static Widget maybeTooltip({required Widget child, String? message}) =>
      (message ?? '').isNotEmpty
          ? Tooltip(message: message!, child: child)
          : child;

  /// Conditionally wraps the [child] with [wrapper] widget if [enabled]
  /// is true.
  static Widget maybeWidget(
          {required WidgetWrapper wrapper,
          required Widget child,
          bool enabled = false}) =>
      enabled ? wrapper(child) : child;
}
