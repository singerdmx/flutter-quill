import 'package:flutter/material.dart';

import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

typedef ToggleStyleButtonBuilder = Widget Function(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize,
  QuillIconTheme? iconTheme,
]);

class QuillToolbarToggleStyleButton extends StatefulWidget {
  const QuillToolbarToggleStyleButton({
    required this.options,
    required this.controller,
    required this.attribute,
    super.key,
  });

  final Attribute attribute;

  final QuillToolbarToggleStyleButtonOptions options;

  final QuillController controller;

  @override
  QuillToolbarToggleStyleButtonState createState() =>
      QuillToolbarToggleStyleButtonState();
}

class QuillToolbarToggleStyleButtonState
    extends State<QuillToolbarToggleStyleButton> {
  bool? _isToggled;

  Style get _selectionStyle => controller.getSelectionStyle();

  QuillToolbarToggleStyleButtonOptions get options {
    return widget.options;
  }

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    controller.addListener(_didChangeEditingValue);
  }

  QuillController get controller {
    return widget.controller;
  }

  double get iconSize {
    final baseFontSize =
        context.requireQuillToolbarBaseButtonOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  double get iconButtonFactor {
    final baseIconFactor =
        context.requireQuillToolbarBaseButtonOptions.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        context.requireQuillToolbarBaseButtonOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ??
        context.requireQuillToolbarBaseButtonOptions.iconTheme;
  }

  (String?, IconData) get _defaultTooltipAndIconData {
    switch (widget.attribute.key) {
      case 'bold':
        return (context.loc.bold, Icons.format_bold);
      case 'script':
        if (widget.attribute.value == ScriptAttributes.sub.value) {
          return (context.loc.subscript, Icons.subscript);
        }
        return (context.loc.superscript, Icons.superscript);
      case 'italic':
        return (context.loc.italic, Icons.format_italic);
      case 'small':
        return (context.loc.small, Icons.format_size);
      case 'underline':
        return (context.loc.underline, Icons.format_underline);
      case 'strike':
        return (context.loc.strikeThrough, Icons.format_strikethrough);
      case 'code':
        return (context.loc.inlineCode, Icons.code);
      case 'direction':
        return (context.loc.textDirection, Icons.format_textdirection_r_to_l);
      case 'list':
        if (widget.attribute.value == 'bullet') {
          return (context.loc.bulletList, Icons.format_list_bulleted);
        }
        return (context.loc.numberedList, Icons.format_list_numbered);
      case 'code-block':
        return (context.loc.codeBlock, Icons.code);
      case 'blockquote':
        return (context.loc.quote, Icons.format_quote);
      default:
        throw ArgumentError(
          'Could not find the default tooltip for '
          '${widget.attribute.toString()}',
        );
    }
  }

  String? get tooltip {
    return options.tooltip ??
        context.requireQuillToolbarBaseButtonOptions.tooltip ??
        _defaultTooltipAndIconData.$1;
  }

  IconData get iconData {
    return options.iconData ??
        context.requireQuillToolbarBaseButtonOptions.iconData ??
        _defaultTooltipAndIconData.$2;
  }

  void _onPressed() {
    _toggleAttribute();
    options.afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder = options.childBuilder ??
        context.requireQuillToolbarBaseButtonOptions.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarToggleStyleButtonOptions(
          afterButtonPressed: options.afterButtonPressed,
          controller: controller,
          fillColor: options.fillColor,
          iconButtonFactor: options.iconButtonFactor,
          iconData: iconData,
          iconSize: iconSize,
          tooltip: tooltip,
          iconTheme: iconTheme,
        ),
        QuillToolbarToggleStyleButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: _onPressed,
          isToggled: _isToggled ?? false,
        ),
      );
    }
    return UtilityWidgets.maybeTooltip(
      message: tooltip,
      child: defaultToggleStyleButtonBuilder(
        context,
        widget.attribute,
        iconData,
        options.fillColor,
        _isToggled,
        _toggleAttribute,
        options.afterButtonPressed,
        iconSize,
        iconButtonFactor,
        iconTheme,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant QuillToolbarToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      controller.addListener(_didChangeEditingValue);
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    setState(() => _isToggled = _getIsToggled(_selectionStyle.attributes));
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    if (widget.attribute.key == Attribute.list.key ||
        widget.attribute.key == Attribute.script.key) {
      final attribute = attrs[widget.attribute.key];
      if (attribute == null) {
        return false;
      }
      return attribute.value == widget.attribute.value;
    }
    return attrs.containsKey(widget.attribute.key);
  }

  void _toggleAttribute() {
    controller.formatSelection(
      _isToggled! ? Attribute.clone(widget.attribute, null) : widget.attribute,
    );
  }
}

Widget defaultToggleStyleButtonBuilder(
  BuildContext context,
  Attribute attribute,
  IconData icon,
  Color? fillColor,
  bool? isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed, [
  double iconSize = kDefaultIconSize,
  double iconButtonFactor = kIconButtonFactor,
  QuillIconTheme? iconTheme,
]) {
  final theme = Theme.of(context);
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled == true
          ? (iconTheme?.iconSelectedColor ??
              theme
                  .primaryIconTheme.color) //You can specify your own icon color
          : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color)
      : (iconTheme?.disabledIconColor ?? theme.disabledColor);
  final fill = isEnabled
      ? isToggled == true
          ? (iconTheme?.iconSelectedFillColor ??
              Theme.of(context).primaryColor) //Selected icon fill color
          : (iconTheme?.iconUnselectedFillColor ??
              theme.canvasColor) //Unselected icon fill color :
      : (iconTheme?.disabledIconFillColor ??
          (fillColor ?? theme.canvasColor)); //Disabled icon fill color
  return QuillToolbarIconButton(
    highlightElevation: 0,
    hoverElevation: 0,
    size: iconSize * iconButtonFactor,
    icon: Icon(icon, size: iconSize, color: iconColor),
    fillColor: fill,
    onPressed: onPressed,
    afterPressed: afterPressed,
    borderRadius: iconTheme?.borderRadius ?? 2,
  );
}
