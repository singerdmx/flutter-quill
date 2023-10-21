import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:flutter/widgets.dart' show IconData, Widget;

import '../../../../../flutter_quill.dart' show QuillController, QuillProvider;
import '../../../themes/quill_icon_theme.dart' show QuillIconTheme;
import '../../quill_configurations.dart' show kDefaultIconSize;

/// The [T] is the options for the button, usually should refresnce itself
/// it's used in [childBuilder] so the developer can custmize this when using it
/// The [I] is extra options for the button, usually for it's state
@immutable
class QuillToolbarBaseButtonOptions<T, I> {
  const QuillToolbarBaseButtonOptions({
    this.iconData,
    this.globalIconSize = kDefaultIconSize,
    this.afterButtonPressed,
    this.tooltip,
    this.iconTheme,
    this.childBuilder,
    this.controller,
  });

  /// By default it will use a Icon data from Icons which comes from material
  /// library, to change this, please pass a different value
  /// If there is no Icon in this button then pass null in the child class
  final IconData? iconData;

  /// To change the the icon size pass a different value, by default will be
  /// [kDefaultIconSize]
  /// this will be used for all the buttons but you can override this
  final double globalIconSize;

  /// To do extra logic after pressing the button
  final VoidCallback? afterButtonPressed;

  /// By default it will use the default tooltip which already localized
  final String? tooltip;

  /// Use custom theme
  final QuillIconTheme? iconTheme;

  /// If you want to dispaly a differnet widget based using a builder
  final Widget Function(T options, I extraOptions)? childBuilder;

  /// By default it will be from the one in [QuillProvider]
  /// To override it you must pass not null controller
  final QuillController? controller;
}
