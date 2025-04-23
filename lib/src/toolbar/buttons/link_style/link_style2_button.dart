import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../../../common/utils/link_validator.dart';
import '../../../common/utils/widgets.dart';

import '../../../editor/widgets/link.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../base_button/base_value_button.dart';

import '../../config/simple_toolbar_config.dart';
import '../../theme/quill_dialog_theme.dart';

import '../quill_icon_button.dart';

typedef QuillToolbarLinkStyleBaseButton2 = QuillToolbarBaseButton<
    QuillToolbarLinkStyleButton2Options,
    QuillToolbarLinkStyleButton2ExtraOptions>;

typedef QuillToolbarLinkStyleBaseButton2State<
        W extends QuillToolbarLinkStyleBaseButton2>
    = QuillToolbarCommonButtonState<W, QuillToolbarLinkStyleButton2Options,
        QuillToolbarLinkStyleButton2ExtraOptions>;

/// Alternative version of [QuillToolbarLinkStyleButton]. This widget has more
/// customization
/// and uses dialog similar to one which is used on [http://quilljs.com].
class QuillToolbarLinkStyleButton2 extends QuillToolbarLinkStyleBaseButton2 {
  QuillToolbarLinkStyleButton2({
    required super.controller,
    super.options = const QuillToolbarLinkStyleButton2Options(),

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : assert(options.addLinkLabel == null ||
            (options.addLinkLabel?.isNotEmpty ?? true)),
        assert(options.editLinkLabel == null ||
            (options.editLinkLabel?.isNotEmpty ?? true)),
        assert(options.childrenSpacing > 0),
        assert(options.validationMessage == null ||
            (options.validationMessage?.isNotEmpty ?? true));

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

  QuillToolbarLinkStyleButton2Options get options {
    return widget.options;
  }

  double get iconButtonFactor {
    return options.iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = options.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarLinkStyleButton2ExtraOptions(
          controller: widget.controller,
          context: context,
          onPressed: () {
            _openLinkDialog();
            options.afterButtonPressed?.call();
          },
        ),
      );
    }
    final isToggled = QuillTextLink.isSelected(widget.controller);
    return QuillToolbarIconButton(
      tooltip: options.tooltip ?? context.loc.insertURL,
      icon: Icon(
        options.iconData ?? Icons.link,
        size: (options.iconSize ?? kDefaultIconSize) * iconButtonFactor,
      ),
      isSelected: isToggled,
      onPressed: _openLinkDialog,
      iconTheme: options.iconTheme,
      afterPressed: options.afterButtonPressed,
    );
  }

  Future<void> _openLinkDialog() async {
    final initialTextLink = QuillTextLink.prepare(widget.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: context,
      builder: (_) => LinkStyleDialog(
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
    );

    if (textLink != null) {
      textLink.submit(widget.controller);
    }
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
            ?.copyWith(fixedSize: WidgetStatePropertyAll(widget.buttonSize))
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

  String? _validateLink(final String? value) {
    final input = value ?? '';

    final errorMessage = LinkValidator.validate(input)
        ? null
        // TODO: Translate
        : (widget.validationMessage ?? 'That is not a valid URL');
    return errorMessage;
  }

  void _applyLink() =>
      Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));

  void _removeLink() =>
      Navigator.pop(context, QuillTextLink(_text.trim(), null));
}
