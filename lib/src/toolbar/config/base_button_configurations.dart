import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:flutter/widgets.dart' show BuildContext, IconData, Widget;

import '../../../flutter_quill.dart' show QuillController;
import '../../editor_toolbar_controller_shared/quill_configurations.dart'
    show kDefaultIconSize, kDefaultIconButtonFactor;
import '../theme/quill_icon_theme.dart' show QuillIconTheme;

class QuillToolbarBaseButtonExtraOptionsIsToggled extends Equatable {
  const QuillToolbarBaseButtonExtraOptionsIsToggled(this.isToggled);

  final bool isToggled;

  @override
  List<Object?> get props => [isToggled];
}

@immutable
class QuillToolbarBaseButtonExtraOptions extends Equatable {
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
  @override
  List<Object?> get props => [
        controller,
      ];
}

/// The [T] is the options for the button, usually should refresnce itself
/// it's used in [childBuilder] so the developer can custmize this when using it
/// The [I] is extra options for the button, usually for it's state
@immutable
class QuillToolbarBaseButtonOptions<T, I> extends Equatable {
  const QuillToolbarBaseButtonOptions({
    this.iconData,
    @Deprecated('This will be removed in future releases, use iconSize instead')
    this.globalIconSize = kDefaultIconSize,
    this.iconSize,
    this.iconButtonFactor,
    @Deprecated(
        'This will be removed in future releases, use iconButtonFactor instead')
    this.globalIconButtonFactor = kDefaultIconButtonFactor,
    this.afterButtonPressed,
    this.tooltip,
    this.iconTheme,
    this.childBuilder,
  });

  /// By default it will use a Icon data from Icons which comes from material
  /// library, to change this, please pass a different value
  /// If there is no Icon in this button then pass null in the child class
  final IconData? iconData;

  /// To change the the icon size pass a different value, by default will be
  /// [kDefaultIconSize].
  /// this will be used for all the buttons but you can override this
  @Deprecated('This will be removed in future releases, use iconSize instead')
  final double globalIconSize;

  /// To change the the icon size pass a different value, by default will be
  /// [kDefaultIconSize].
  /// this will be used for all the buttons but you can override this
  final double? iconSize;

  /// The factor of how much larger the button is in relation to the icon,
  /// by default it will be [kDefaultIconButtonFactor].
  @Deprecated(
      'This will be removed in future releases, use iconButtonFactor instead')
  final double globalIconButtonFactor;

  final double? iconButtonFactor;

  /// To do extra logic after pressing the button
  final VoidCallback? afterButtonPressed;

  /// By default it will use the default tooltip which already localized
  final String? tooltip;

  /// Use custom theme
  final QuillIconTheme? iconTheme;

  /// If you want to dispaly a differnet widget based using a builder
  final QuillToolbarButtonOptionsChildBuilder<T, I> childBuilder;

  @override
  List<Object?> get props => [
        iconData,
        iconSize,
        iconButtonFactor,
        afterButtonPressed,
        tooltip,
        iconTheme,
        childBuilder,
      ];
}

typedef QuillToolbarButtonOptionsChildBuilder<T, I> = Widget Function(
  T options,
  I extraOptions,
)?;
