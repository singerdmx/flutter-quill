import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../base_button_options.dart';

/// Extra options provided to the child builder for [QuillToolbarUserMentionButton].
///
/// Contains the controller, context, and onPressed callback that can be used
/// when building a custom button widget via [QuillToolbarUserMentionButtonOptions.childBuilder].
class QuillToolbarUserMentionButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  /// Creates extra options for the user mention button.
  ///
  /// [controller] - The QuillController instance managing the editor.
  /// [context] - The BuildContext for the button widget.
  /// [onPressed] - Callback to execute when the button is pressed (inserts '@').
  const QuillToolbarUserMentionButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

/// Configuration options for [QuillToolbarUserMentionButton].
///
/// Allows customization of the button's appearance, tooltip, and behavior.
/// All options are optional and will use sensible defaults if not provided.
@immutable
class QuillToolbarUserMentionButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillToolbarUserMentionButtonOptions,
        QuillToolbarUserMentionButtonExtraOptions> {
  /// Creates options for the user mention button.
  ///
  /// [iconData] - Custom icon to display (defaults to [Icons.alternate_email]).
  /// [iconSize] - Size of the icon (defaults to [kDefaultIconSize]).
  /// [iconButtonFactor] - Factor to multiply icon size by (defaults to [kDefaultIconButtonFactor]).
  /// [tooltip] - Tooltip text to show on hover (defaults to 'Mention').
  /// [afterButtonPressed] - Callback executed after the button is pressed.
  /// [iconTheme] - Theme for the icon button.
  /// [childBuilder] - Custom builder for the button widget (allows full customization).
  const QuillToolbarUserMentionButtonOptions({
    super.iconData,
    super.iconSize,
    super.iconButtonFactor,
    super.tooltip,
    super.afterButtonPressed,
    super.iconTheme,
    super.childBuilder,
  });
}
