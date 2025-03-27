import 'package:flutter/material.dart';

import '../../common/utils/link_validator.dart';
import '../../editor/widgets/link.dart';
import '../../l10n/extensions/localizations_ext.dart';
import '../../rules/insert.dart';
import '../base_button/base_value_button.dart';

import '../config/buttons/link_style_options.dart';
import '../structs/link_dialog_action.dart';
import '../theme/quill_dialog_theme.dart';
import 'quill_icon_button.dart';

typedef QuillToolbarLinkStyleBaseButton = QuillToolbarBaseButton<
    QuillToolbarLinkStyleButtonOptions,
    QuillToolbarLinkStyleButtonExtraOptions>;

typedef QuillToolbarLinkStyleBaseButtonState<
        W extends QuillToolbarLinkStyleBaseButton>
    = QuillToolbarCommonButtonState<W, QuillToolbarLinkStyleButtonOptions,
        QuillToolbarLinkStyleButtonExtraOptions>;

class QuillToolbarLinkStyleButton extends QuillToolbarLinkStyleBaseButton {
  const QuillToolbarLinkStyleButton({
    required super.controller,
    super.options = const QuillToolbarLinkStyleButtonOptions(),

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  });

  @override
  QuillToolbarLinkStyleButtonState createState() =>
      QuillToolbarLinkStyleButtonState();
}

class QuillToolbarLinkStyleButtonState
    extends QuillToolbarLinkStyleBaseButtonState {
  @override
  String get defaultTooltip => context.loc.insertURL;

  void _didChangeSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_didChangeSelection);
  }

  @override
  void didUpdateWidget(covariant QuillToolbarLinkStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeSelection);
      controller.addListener(_didChangeSelection);
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_didChangeSelection);
  }

  @override
  IconData get defaultIconData => Icons.link;

  @override
  Widget build(BuildContext context) {
    final isToggled = QuillTextLink.isSelected(controller);

    final childBuilder = this.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
        QuillToolbarLinkStyleButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () {
            _openLinkDialog(context);
            afterButtonPressed?.call();
          },
        ),
      );
    }
    return QuillToolbarIconButton(
      tooltip: tooltip,
      icon: Icon(
        iconData,
        size: iconSize * iconButtonFactor,
      ),
      isSelected: isToggled,
      onPressed: () => _openLinkDialog(context),
      afterPressed: afterButtonPressed,
      iconTheme: iconTheme,
    );
  }

  Future<void> _openLinkDialog(BuildContext context) async {
    final initialTextLink = QuillTextLink.prepare(widget.controller);

    final textLink = await showDialog<QuillTextLink>(
      context: context,
      builder: (_) {
        return _LinkDialog(
          validateLink: options.validateLink,
          // ignore: deprecated_member_use_from_same_package
          legacyLinkRegExp: options.linkRegExp,
          dialogTheme: options.dialogTheme,
          text: initialTextLink.text,
          link: initialTextLink.link,
          action: options.linkDialogAction,
        );
      },
    );
    if (textLink != null) {
      textLink.submit(widget.controller);
    }
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({
    required this.validateLink,
    this.dialogTheme,
    this.link,
    this.text,
    this.legacyLinkRegExp,
    this.action,
  });

  final QuillDialogTheme? dialogTheme;
  final String? link;
  final String? text;
  final RegExp? legacyLinkRegExp;
  final LinkValidationCallback? validateLink;
  final LinkDialogAction? action;

  @override
  _LinkDialogState createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  late String _link;
  late String _text;

  @Deprecated(
      'Will be removed in future-releases, please migrate to QuillToolbarLinkStyleButtonOptions.validateLink.')
  RegExp get linkRegExp {
    return widget.legacyLinkRegExp ??
        AutoFormatMultipleLinksRule.singleLineUrlRegExp;
  }

  late TextEditingController _linkController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _link = widget.link ?? '';
    _text = widget.text ?? '';
    _linkController = TextEditingController(text: _link);
    _textController = TextEditingController(text: _text);
  }

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogTheme?.dialogBackgroundColor,
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.text,
              style: widget.dialogTheme?.inputTextStyle,
              decoration: InputDecoration(
                labelText: context.loc.text,
                hintText: context.loc.pleaseEnterTextForYourLink,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
              ),
              autofocus: true,
              onChanged: _textChanged,
              controller: _textController,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.name,
                AutofillHints.url,
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.url,
              style: widget.dialogTheme?.inputTextStyle,
              decoration: InputDecoration(
                labelText: context.loc.link,
                hintText: context.loc.pleaseEnterTheLinkURL,
                labelStyle: widget.dialogTheme?.labelTextStyle,
                floatingLabelStyle: widget.dialogTheme?.labelTextStyle,
              ),
              onChanged: _linkChanged,
              controller: _linkController,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.url],
              autocorrect: false,
              onEditingComplete: () {
                if (!_canPress()) {
                  return;
                }
                _applyLink();
              },
            ),
          ],
        ),
      ),
      actions: [
        _okButton(),
      ],
    );
  }

  Widget _okButton() {
    if (widget.action != null) {
      return widget.action!.builder(
        _canPress(),
        _applyLink,
      );
    }

    return TextButton(
      onPressed: _canPress() ? _applyLink : null,
      child: Text(
        context.loc.ok,
        style: widget.dialogTheme?.buttonTextStyle,
      ),
    );
  }

  bool get _isLinkValid => LinkValidator.validate(
        _link,
        customValidateLink: widget.validateLink,
        // Implemented for backward compatibility, clients should use validateLink instead.
        legacyRegex: widget.legacyLinkRegExp,
      );

  bool _canPress() {
    if (_text.isEmpty || _link.isEmpty) {
      return false;
    }
    return _isLinkValid;
  }

  void _linkChanged(String value) {
    setState(() {
      _link = value;
    });
  }

  void _textChanged(String value) {
    setState(() {
      _text = value;
    });
  }

  void _applyLink() {
    Navigator.pop(context, QuillTextLink(_text.trim(), _link.trim()));
  }
}
