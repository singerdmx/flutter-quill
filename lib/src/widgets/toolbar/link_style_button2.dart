import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../extensions.dart';
import '../../../translations.dart';
import '../../models/documents/attribute.dart';
import '../../models/themes/quill_dialog_theme.dart';
import '../../models/themes/quill_icon_theme.dart';
import '../controller.dart';
import '../link.dart';
import '../toolbar.dart';

/// Alternative version of [LinkStyleButton]. This widget has more customization
/// and uses dialog similar to one which is used on [http://quilljs.com].
class LinkStyleButton2 extends StatefulWidget {
  const LinkStyleButton2({
    required this.controller,
    this.icon,
    this.iconSize = kDefaultIconSize,
    this.iconTheme,
    this.dialogTheme,
    this.afterButtonPressed,
    this.tooltip,
    this.constraints,
    this.addLinkLabel,
    this.editLinkLabel,
    this.linkColor,
    this.childrenSpacing = 16.0,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.validationMessage,
    this.buttonSize,
    Key? key,
  })  : assert(addLinkLabel == null || addLinkLabel.length > 0),
        assert(editLinkLabel == null || editLinkLabel.length > 0),
        assert(childrenSpacing > 0),
        assert(validationMessage == null || validationMessage.length > 0),
        super(key: key);

  final QuillController controller;
  final IconData? icon;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final QuillDialogTheme? dialogTheme;
  final VoidCallback? afterButtonPressed;
  final String? tooltip;

  /// The constrains for dialog.
  final BoxConstraints? constraints;

  /// The text of label in link add mode.
  final String? addLinkLabel;

  /// The text of label in link edit mode.
  final String? editLinkLabel;

  /// The color of URL.
  final Color? linkColor;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  /// The size of dialog buttons.
  final Size? buttonSize;

  @override
  State<LinkStyleButton2> createState() => _LinkStyleButton2State();
}

class _LinkStyleButton2State extends State<LinkStyleButton2> {
  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(_didChangeSelection);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant LinkStyleButton2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToggled = _getLinkAttributeValue() != null;
    return QuillIconButton(
      tooltip: widget.tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * kIconButtonFactor,
      icon: Icon(
        widget.icon ?? Icons.link,
        size: widget.iconSize,
        color: isToggled
            ? (widget.iconTheme?.iconSelectedColor ??
                theme.primaryIconTheme.color)
            : (widget.iconTheme?.iconUnselectedColor ?? theme.iconTheme.color),
      ),
      fillColor: isToggled
          ? (widget.iconTheme?.iconSelectedFillColor ??
              Theme.of(context).primaryColor)
          : (widget.iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
      borderRadius: widget.iconTheme?.borderRadius ?? 2,
      onPressed: _openLinkDialog,
      afterPressed: widget.afterButtonPressed,
    );
  }

  Future<void> _openLinkDialog() async {
    final initialTextLink = QuillTextLink.prepare(widget.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: context,
      builder: (_) => LinkStyleDialog(
        dialogTheme: widget.dialogTheme,
        text: initialTextLink.text,
        link: initialTextLink.link,
        constraints: widget.constraints,
        addLinkLabel: widget.addLinkLabel,
        editLinkLabel: widget.editLinkLabel,
        linkColor: widget.linkColor,
        childrenSpacing: widget.childrenSpacing,
        autovalidateMode: widget.autovalidateMode,
        validationMessage: widget.validationMessage,
        buttonSize: widget.buttonSize,
      ),
    );

    if (textLink != null) {
      textLink.submit(widget.controller);
    }
  }

  String? _getLinkAttributeValue() {
    return widget.controller
        .getSelectionStyle()
        .attributes[Attribute.link.key]
        ?.value;
  }

  void _didChangeSelection() {
    setState(() {});
  }
}

class LinkStyleDialog extends StatefulWidget {
  const LinkStyleDialog({
    Key? key,
    this.text,
    this.link,
    this.dialogTheme,
    this.constraints,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    this.addLinkLabel,
    this.editLinkLabel,
    this.linkColor,
    this.childrenSpacing = 16.0,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.validationMessage,
    this.buttonSize,
  })  : assert(addLinkLabel == null || addLinkLabel.length > 0),
        assert(editLinkLabel == null || editLinkLabel.length > 0),
        assert(childrenSpacing > 0),
        assert(validationMessage == null || validationMessage.length > 0),
        super(key: key);

  final String? text;
  final String? link;
  final QuillDialogTheme? dialogTheme;

  /// The constrains for dialog.
  final BoxConstraints? constraints;

  /// The padding for content of dialog.
  final EdgeInsetsGeometry contentPadding;

  /// The text of label in link add mode.
  final String? addLinkLabel;

  /// The text of label in link edit mode.
  final String? editLinkLabel;

  /// The color of URL.
  final Color? linkColor;

  /// The margin between child widgets in the dialog.
  final double childrenSpacing;

  final AutovalidateMode autovalidateMode;
  final String? validationMessage;

  /// The size of dialog buttons.
  final Size? buttonSize;

  @override
  State<LinkStyleDialog> createState() => _LinkStyleDialogState();
}

class _LinkStyleDialogState extends State<LinkStyleDialog> {
  late final TextEditingController _linkController;

  late String _link;
  late String _text;

  late bool _isEditMode;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _isEditMode = _link.isNotEmpty;
    _linkController = TextEditingController.fromValue(
      TextEditingValue(
        text: _isEditMode ? _link : '',
        selection: _isEditMode
            ? TextSelection(baseOffset: 0, extentOffset: _link.length)
            : const TextSelection.collapsed(offset: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final constraints = widget.constraints ??
        widget.dialogTheme?.linkDialogConstraints ??
        () {
          final mediaQuery = MediaQuery.of(context);
          final maxWidth =
              kIsWeb ? mediaQuery.size.width / 4 : mediaQuery.size.width - 80;
          return BoxConstraints(maxWidth: maxWidth, maxHeight: 80);
        }();

    final buttonStyle = widget.buttonSize != null
        ? Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.copyWith(fixedSize: MaterialStatePropertyAll(widget.buttonSize))
        : widget.dialogTheme?.buttonStyle;

    final isWrappable = widget.dialogTheme?.isWrappable ?? false;

    final children = _isEditMode
        ? [
            Text(widget.editLinkLabel ?? 'Visit link'.i18n),
            UtilityWidgets.maybeWidget(
              enabled: !isWrappable,
              wrapper: (child) => Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: widget.childrenSpacing),
                child: Link(
                  uri: Uri.parse(_linkController.text),
                  builder: (context, followLink) {
                    return TextButton(
                      onPressed: followLink,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        widget.link!,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: widget.dialogTheme?.inputTextStyle?.copyWith(
                          color: widget.linkColor ?? Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              style: buttonStyle,
              child: Text('Edit'.i18n),
            ),
            Padding(
              padding: EdgeInsets.only(left: widget.childrenSpacing),
              child: ElevatedButton(
                onPressed: _removeLink,
                style: buttonStyle,
                child: Text('Remove'.i18n),
              ),
            ),
          ]
        : [
            Text(widget.addLinkLabel ?? 'Enter link'.i18n),
            UtilityWidgets.maybeWidget(
              enabled: !isWrappable,
              wrapper: (child) => Expanded(
                child: child,
              ),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: widget.childrenSpacing),
                child: TextFormField(
                  controller: _linkController,
                  style: widget.dialogTheme?.inputTextStyle,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelStyle: widget.dialogTheme?.labelTextStyle,
                  ),
                  autofocus: true,
                  autovalidateMode: widget.autovalidateMode,
                  validator: _validateLink,
                  onChanged: _linkChanged,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _canPress() ? _applyLink : null,
              style: buttonStyle,
              child: Text('Apply'.i18n),
            ),
          ];

    return Dialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      shape: widget.dialogTheme?.shape ??
          DialogTheme.of(context).shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: constraints,
        child: Padding(
          padding: widget.contentPadding,
          child: isWrappable
              ? Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: widget.dialogTheme?.runSpacing ?? 0.0,
                  children: children,
                )
              : Row(
                  children: children,
                ),
        ),
      ),
    );
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  bool _canPress() => _validateLink(_link) == null;

  String? _validateLink(String? value) {
    if ((value?.isEmpty ?? false) ||
        !AutoFormatMultipleLinksRule.linkRegExp.hasMatch(value!)) {
      return widget.validationMessage ?? 'That is not a valid URL';
    }

    return null;
  }

  void _applyLink() =>
      Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));

  void _removeLink() =>
      Navigator.pop(context, QuillTextLink(_text.trim(), null));
}

/// Contains information about text URL.
class QuillTextLink {
  QuillTextLink(
    this.text,
    this.link,
  );

  final String text;
  final String? link;

  static QuillTextLink prepare(QuillController controller) {
    final link =
        controller.getSelectionStyle().attributes[Attribute.link.key]?.value;
    final index = controller.selection.start;

    var text;
    if (link != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        text = leaf.toPlainText();
      }
    }

    final len = controller.selection.end - index;
    text ??= len == 0 ? '' : controller.document.getPlainText(index, len);

    return QuillTextLink(text, link);
  }

  void submit(QuillController controller) {
    var index = controller.selection.start;
    var length = controller.selection.end - index;
    final linkValue =
        controller.getSelectionStyle().attributes[Attribute.link.key]?.value;

    if (linkValue != null) {
      // text should be the link's corresponding text, not selection
      final leaf = controller.document.querySegmentLeafNode(index).leaf;
      if (leaf != null) {
        final range = getLinkRange(leaf);
        index = range.start;
        length = range.end - range.start;
      }
    }
    controller
      ..replaceText(index, length, text, null)
      ..formatText(index, text.length, LinkAttribute(link));
  }
}
