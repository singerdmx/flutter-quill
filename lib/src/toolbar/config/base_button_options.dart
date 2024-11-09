import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:flutter/widgets.dart' show BuildContext, IconData, Widget;

import '../../controller/quill_controller.dart';
import '../../editor_toolbar_controller_shared/quill_config.dart'
    show kDefaultIconSize;
import '../theme/quill_icon_theme.dart' show QuillIconTheme;

class QuillToolbarBaseButtonExtraOptionsIsToggled {
  const QuillToolbarBaseButtonExtraOptionsIsToggled(this.isToggled);

  final bool isToggled;
}

@immutable
class QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarBaseButtonExtraOptions({
    required this.controller,
    required this.context,
    required this.onPressed,
  });

  final QuillController controller;

  /// if the child builder you must use this when the widget tapped or pressed
  /// in order to do what it expected to do
  final VoidCallback? onPressed;

  final BuildContext context;
}

/// The [T] is the options for the button, usually should refresnce itself
/// it's used in [childBuilder] so the developer can customize this when using it
/// The [I] is extra options for the button, usually for it's state
@immutable
class QuillToolbarBaseButtonOptions<T, I> {
  const QuillToolbarBaseButtonOptions({
    this.iconData,
    this.iconSize,
    this.iconButtonFactor,
    this.afterButtonPressed,
    this.tooltip,
    this.iconTheme,
    this.childBuilder,
  });

  /// By default it will use a Icon data from Icons which comes from material
  /// library, to change this, please pass a different value
  /// If there is no Icon in this button then pass `null` in the child class
  final IconData? iconData;

  /// To change the the icon size pass a different value, by default will be
  /// [kDefaultIconSize].
  /// this will be used for all the buttons but you can override this
  final double? iconSize;

  final double? iconButtonFactor;

  /// To do extra logic after pressing the button
  final VoidCallback? afterButtonPressed;

  /// By default it will use the default tooltip which already localized
  final String? tooltip;

  /// Use custom theme
  final QuillIconTheme? iconTheme;

  /// If you want to display a different widget based using a builder
  final QuillToolbarButtonOptionsChildBuilder<T, I> childBuilder;
}

typedef QuillToolbarButtonOptionsChildBuilder<T, I> = Widget Function(
  T options,
  I extraOptions,
)?;
