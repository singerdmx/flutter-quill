// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:flutter/widgets.dart' show BuildContext, IconData, Widget;

import '../../../../../flutter_quill.dart' show QuillController, QuillProvider;
import '../../../themes/quill_icon_theme.dart' show QuillIconTheme;
import '../../quill_configurations.dart'
    show kDefaultIconSize, kIconButtonFactor;

@immutable
class QuillToolbarBaseButtonExtraOptions extends Equatable {
  const QuillToolbarBaseButtonExtraOptions({
    required this.controller,
    required this.context,
    required this.onPressed,
  });

  /// if you need the not null controller for some usage in the [childBuilder]
  /// then please use this instead of the one in the [options]
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
    this.globalIconSize = kDefaultIconSize,
    this.globalIconButtonFactor = kIconButtonFactor,
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
  /// [kDefaultIconSize].
  /// this will be used for all the buttons but you can override this
  final double globalIconSize;

  /// The factor of how much larger the button is in relation to the icon,
  /// by default it will be [kIconButtonFactor].
  final double globalIconButtonFactor;

  /// To do extra logic after pressing the button
  final VoidCallback? afterButtonPressed;

  /// By default it will use the default tooltip which already localized
  final String? tooltip;

  /// Use custom theme
  final QuillIconTheme? iconTheme;

  /// If you want to dispaly a differnet widget based using a builder
  final QuillToolbarButtonOptionsChildBuilder<T, I> childBuilder;

  /// By default it will be from the one in [QuillProvider]
  /// To override it you must pass not null controller
  /// if you wish to use the controller in the [childBuilder], please use the
  /// one from the extraOptions since it will be not null and will be the one
  /// which will be used from the quill toolbar
  final QuillController? controller;

  @override
  List<Object?> get props => [
        iconData,
        globalIconSize,
        afterButtonPressed,
        tooltip,
        iconTheme,
        childBuilder,
        controller,
      ];
}

typedef QuillToolbarButtonOptionsChildBuilder<T, I> = Widget Function(
  T options,
  I extraOptions,
)?;
