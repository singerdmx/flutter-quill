import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../../translations/toolbar.i18n.dart';
import '../controller.dart';
import '../link_dialog.dart';
import '../toolbar.dart';
import 'quill_icon_button.dart';

class LinkStyleButton extends StatefulWidget {
  const LinkStyleButton({
    required this.controller,
    this.iconSize = kDefaultIconSize,
    this.icon,
    this.iconTheme,
    this.dialogTheme,
    Key? key,
  }) : super(key: key);

  final QuillController controller;
  final IconData? icon;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;

  @override
  _LinkStyleButtonState createState() => _LinkStyleButtonState();
}

class _LinkStyleButtonState extends State<LinkStyleButton> {
  void _didChangeSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant LinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_didChangeSelection);
  }

  final GlobalKey _toolTipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.controller.selection.isCollapsed;
    final pressedHandler = isEnabled ? () => _openLinkDialog(context) : null;
    return GestureDetector(
      onTap: () async {
        final dynamic tooltip = _toolTipKey.currentState;
        tooltip.ensureTooltipVisible();
        Future.delayed(
          const Duration(
            seconds: 3,
          ),
          tooltip.deactivate,
        );
      },
      child: Tooltip(
        key: _toolTipKey,
        message: 'Please first select some text to transform into a link.'.i18n,
        child: QuillIconButton(
          highlightElevation: 0,
          hoverElevation: 0,
          size: widget.iconSize * kIconButtonFactor,
          icon: Icon(
            widget.icon ?? Icons.link,
            size: widget.iconSize,
            color: isEnabled
                ? (widget.iconTheme?.iconUnselectedColor ??
                    theme.iconTheme.color)
                : (widget.iconTheme?.disabledIconColor ?? theme.disabledColor),
          ),
          fillColor:
              widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor,
          onPressed: pressedHandler,
        ),
      ),
    );
  }

  void _openLinkDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        return LinkDialog(dialogTheme: widget.dialogTheme);
      },
    ).then(_linkSubmitted);
  }

  void _linkSubmitted(String? value) {
    if (value == null || value.isEmpty) {
      return;
    }
    widget.controller.formatSelection(LinkAttribute(value));
  }
}
