import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../../extensions.dart'
    show UtilityWidgets, AutoFormatMultipleLinksRule;
import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../l10n/widgets/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/themes/quill_dialog_theme.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../../link.dart';
import '../../utils/provider.dart';
import '../base_toolbar.dart';

/// Alternative version of [QuillToolbarLinkStyleButton]. This widget has more
/// customization
/// and uses dialog similar to one which is used on [http://quilljs.com].
class QuillToolbarLinkStyleButton2 extends StatefulWidget {
  QuillToolbarLinkStyleButton2({
    required this.controller,
    required this.options,
    super.key,
  })  : assert(options.addLinkLabel == null ||
            (options.addLinkLabel?.isNotEmpty ?? true)),
        assert(options.editLinkLabel == null ||
            (options.editLinkLabel?.isNotEmpty ?? true)),
        assert(options.childrenSpacing > 0),
        assert(options.validationMessage == null ||
            (options.validationMessage?.isNotEmpty ?? true));

  final QuillController controller;
  final QuillToolbarLinkStyleButton2Options options;

  @override
  State<QuillToolbarLinkStyleButton2> createState() =>
      _QuillToolbarLinkStyleButton2State();
}

class _QuillToolbarLinkStyleButton2State
    extends State<QuillToolbarLinkStyleButton2> {
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
  void didUpdateWidget(covariant QuillToolbarLinkStyleButton2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      widget.controller.addListener(_didChangeSelection);
    }
  }

  QuillController get controller {
    return widget.controller;
  }

  QuillToolbarLinkStyleButton2Options get options {
    return widget.options;
  }

  double get iconSize {
    final baseFontSize = baseButtonExtraOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions.iconTheme;
  }

  QuillToolbarBaseButtonOptions get baseButtonExtraOptions {
    return context.requireQuillToolbarBaseButtonOptions;
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        context.loc.insertURL;
  }

  IconData get iconData {
    return options.iconData ?? baseButtonExtraOptions.iconData ?? Icons.link;
  }

  Color get dialogBarrierColor {
    return options.dialogBarrierColor ??
        context.requireQuillSharedConfigurations.dialogBarrierColor;
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarLinkStyleButton2Options(
          iconData: iconData,
          addLinkLabel: options.addLinkLabel,
          afterButtonPressed: options.afterButtonPressed,
          autovalidateMode: options.autovalidateMode,
          buttonSize: options.buttonSize,
          childrenSpacing: options.childrenSpacing,
          dialogBarrierColor: dialogBarrierColor,
          dialogTheme: options.dialogTheme,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          constraints: options.constraints,
          tooltip: tooltip,
          iconTheme: iconTheme,
          editLinkLabel: options.editLinkLabel,
          validationMessage: options.validationMessage,
          linkColor: options.linkColor,
        ),
        QuillToolbarLinkStyleButton2ExtraOptions(
          controller: controller,
          context: context,
          onPressed: () {
            _openLinkDialog();
            afterButtonPressed?.call();
          },
        ),
      );
    }
    final theme = Theme.of(context);
    final isToggled = _getLinkAttributeValue() != null;
    return QuillToolbarIconButton(
      tooltip: tooltip,
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * iconButtonFactor,
      icon: Icon(
        iconData,
        size: iconSize,
        color: isToggled
            ? (iconTheme?.iconSelectedColor ?? theme.primaryIconTheme.color)
            : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color),
      ),
      fillColor: isToggled
          ? (iconTheme?.iconSelectedFillColor ?? theme.primaryColor)
          : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
      borderRadius: iconTheme?.borderRadius ?? 2,
      onPressed: _openLinkDialog,
      afterPressed: afterButtonPressed,
    );
  }

  Future<void> _openLinkDialog() async {
    final initialTextLink = QuillTextLink.prepare(widget.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: context,
      barrierColor: dialogBarrierColor,
      builder: (_) => QuillProvider.value(
        value: context.requireQuillProvider,
        child: FlutterQuillLocalizationsWidget(
          child: LinkStyleDialog(
            dialogTheme: options.dialogTheme,
            text: initialTextLink.text,
            link: initialTextLink.link,
            constraints: options.constraints,
            addLinkLabel: options.addLinkLabel,
            editLinkLabel: options.editLinkLabel,
            linkColor: options.linkColor,
            childrenSpacing: options.childrenSpacing,
            autovalidateMode: options.autovalidateMode,
            validationMessage: options.validationMessage,
            buttonSize: options.buttonSize,
          ),
        ),
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
    super.key,
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
        assert(validationMessage == null || validationMessage.length > 0);

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
          final size = MediaQuery.sizeOf(context);
          final maxWidth = kIsWeb ? size.width / 4 : size.width - 80;
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
            Text(widget.editLinkLabel ?? context.loc.visitLink),
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
              child: Text(context.loc.edit),
            ),
            Padding(
              padding: EdgeInsets.only(left: widget.childrenSpacing),
              child: ElevatedButton(
                onPressed: _removeLink,
                style: buttonStyle,
                child: Text(context.loc.remove),
              ),
            ),
          ]
        : [
            Text(widget.addLinkLabel ?? context.loc.enterLink),
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
              child: Text(context.loc.apply),
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
        !AutoFormatMultipleLinksRule.oneLineLinkRegExp.hasMatch(value!)) {
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

    String? text;
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
