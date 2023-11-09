import 'package:flutter/widgets.dart' show Color;

import '../../../../widgets/toolbar/base_toolbar.dart';
import '../../../structs/link_dialog_action.dart';
import '../../../themes/quill_dialog_theme.dart';

class QuillToolbarLinkStyleButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarLinkStyleButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
  });
}

class QuillToolbarLinkStyleButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarLinkStyleButtonOptions,
    QuillToolbarLinkStyleButtonExtraOptions> {
  const QuillToolbarLinkStyleButtonOptions({
    this.dialogTheme,
    this.linkRegExp,
    this.linkDialogAction,
    this.dialogBarrierColor,
    this.iconSize,
    this.iconButtonFactor,
    super.iconData,
    super.globalIconSize,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    super.controller,
  });

  final double? iconSize;
  final double? iconButtonFactor;
  final QuillDialogTheme? dialogTheme;
  final RegExp? linkRegExp;
  final LinkDialogAction? linkDialogAction;
  final Color? dialogBarrierColor;
}
