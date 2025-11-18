import 'package:flutter/widgets.dart';

extension ViewIdExt on BuildContext {
  int? getViewId() {
    late final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    return View.maybeOf(this)?.viewId ??
        // If context has no View, check platformDispatcher
        platformDispatcher.views.firstOrNull?.viewId ??
        platformDispatcher.implicitView?.viewId;
  }
}
