import 'package:flutter/widgets.dart' show Color;

import '../../../editor/widgets/link.dart';
import '../../base_toolbar.dart';
import '../../structs/link_dialog_action.dart';
import '../../theme/quill_dialog_theme.dart';

class QuillToolbarLinkStyleButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarLinkStyleButtonExtraOptions({
    required super.controller,
    required super.context,
    required this.textLink,
    required super.onPressed,
  });
  final QuillTextLink textLink;
}

class QuillToolbarLinkStyleButtonOptions extends QuillToolbarBaseButtonOptions<
    QuillToolbarLinkStyleButtonOptions,
    QuillToolbarLinkStyleButtonExtraOptions> {
  const QuillToolbarLinkStyleButtonOptions({
    this.dialogTheme,
    this.linkRegExp,
    this.linkDialogAction,
    this.dialogBarrierColor,
    super.iconSize,
    super.iconButtonFactor,
    super.iconData,
    super.globalIconSize,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
  });

  final QuillDialogTheme? dialogTheme;
  final RegExp? linkRegExp;
  final LinkDialogAction? linkDialogAction;
  final Color? dialogBarrierColor;
}
