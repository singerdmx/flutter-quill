import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../base_button_options.dart';

/// Extra options provided to the child builder for [QuillToolbarHashtagButton].
///
/// Contains the controller, context, and onPressed callback that can be used
/// when building a custom button widget via [QuillToolbarHashtagButtonOptions.childBuilder].
class QuillToolbarHashtagButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  /// Creates extra options for the hashtag button.
  ///
  /// [controller] - The QuillController instance managing the editor.
  /// [context] - The BuildContext for the button widget.
  /// [onPressed] - Callback to execute when the button is pressed (inserts '#').
  const QuillToolbarHashtagButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

/// Configuration options for [QuillToolbarHashtagButton].
///
/// Allows customization of the button's appearance, tooltip, and behavior.
/// All options are optional and will use sensible defaults if not provided.
@immutable
class QuillToolbarHashtagButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillToolbarHashtagButtonOptions,
        QuillToolbarHashtagButtonExtraOptions> {
  /// Creates options for the hashtag button.
  ///
  /// [iconData] - Custom icon to display (defaults to [Icons.tag]).
  /// [iconSize] - Size of the icon (defaults to [kDefaultIconSize]).
  /// [iconButtonFactor] - Factor to multiply icon size by (defaults to [kDefaultIconButtonFactor]).
  /// [tooltip] - Tooltip text to show on hover (defaults to 'Tag').
  /// [afterButtonPressed] - Callback executed after the button is pressed.
  /// [iconTheme] - Theme for the icon button.
  /// [childBuilder] - Custom builder for the button widget (allows full customization).
  const QuillToolbarHashtagButtonOptions({
    super.iconData,
    super.iconSize,
    super.iconButtonFactor,
    super.tooltip,
    super.afterButtonPressed,
    super.iconTheme,
    super.childBuilder,
  });
}
