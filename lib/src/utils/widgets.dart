import 'package:flutter/material.dart';

/// Provides utiulity widgets.
abstract class UtilityWidgets {
  /// Conditionally wraps the [child] with [Tooltip] widget if [message]
  /// is not null and not empty.
  static Widget maybeTooltip({required Widget child, String? message}) =>
      (message ?? '').isNotEmpty
          ? Tooltip(message: message!, child: child)
          : child;
}
