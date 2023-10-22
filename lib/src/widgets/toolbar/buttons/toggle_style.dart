import 'package:flutter/material.dart';

import '../../../../translations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/extensions/build_context.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';
import '../toolbar.dart';

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
    // required this.icon,
    // required this.controller,
    // this.iconSize = kDefaultIconSize,
    // this.fillColor,
    // this.childBuilder = defaultToggleStyleButtonBuilder,
    // this.iconTheme,
    // this.afterButtonPressed,
    // this.tooltip,
    super.key,
  });

  final Attribute attribute;

  // final IconData icon;
  // final double iconSize;

  // final Color? fillColor;

  // final QuillController controller;

  // final ToggleStyleButtonBuilder childBuilder;

  // ///Specify an icon theme for the icons in the toolbar
  // final QuillIconTheme? iconTheme;

  // final VoidCallback? afterButtonPressed;
  // final String? tooltip;
  final QuillToolbarToggleStyleButtonOptions options;

  /// Since we can't get the state from the instace of the widget for comparing
  /// in [didUpdateWidget] then we will have to store reference here
  final QuillController controller;

  @override
  _QuillToolbarToggleStyleButtonState createState() =>
      _QuillToolbarToggleStyleButtonState();
}

class _QuillToolbarToggleStyleButtonState
    extends State<QuillToolbarToggleStyleButton> {
  /// Since it's not safe to call anything related to the context in dispose
  /// then we will save a reference to the [controller]
  /// and update it in [didChangeDependencies]
  /// and use it in dispose method
  late QuillController _controller;

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
    return options.controller ?? widget.controller;
  }

  double get iconSize {
    final baseFontSize =
        context.requireQuillToolbarBaseButtonOptions.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        context.requireQuillToolbarBaseButtonOptions.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ??
        context.requireQuillToolbarBaseButtonOptions.iconTheme;
  }

  String? get _defaultTooltip {
    switch (widget.attribute.key) {
      case 'bold':
        return 'Bold'.i18n;
      case 'script':
        if (widget.attribute.value == ScriptAttributes.sub.value) {
          return 'Subscript'.i18n;
        }
        return 'Superscript'.i18n;
      case 'italic':
        return 'Italic'.i18n;
      case 'small':
        return 'Small'.i18n;
      case 'underline':
        return 'Underline'.i18n;
      case 'strike':
        return 'Strike through'.i18n;
      case 'code':
        return 'Inline code'.i18n;
      case 'rtl':
        return 'Text direction'.i18n;
      case 'list':
        if (widget.attribute.value == 'bullet') {
          return 'Bullet list'.i18n;
        }
        return 'Numbered list'.i18n;
      case 'code-block':
        return 'Code block'.i18n;
      case 'blockquote':
        return 'Quote'.i18n;
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
        _defaultTooltip;
  }

  IconData get _defaultIconData {
    switch (widget.attribute.key) {
      case 'bold':
        return Icons.format_bold;
      case 'script':
        if (widget.attribute.value == ScriptAttributes.sub.value) {
          return Icons.subscript;
        }
        return Icons.superscript;
      case 'italic':
        return Icons.format_italic;
      case 'small':
        return Icons.format_size;
      case 'underline':
        return Icons.format_underline;
      case 'strike':
        return Icons.format_strikethrough;
      case 'code':
        return Icons.code;
      case 'rtl':
        return Icons.format_textdirection_r_to_l;
      case 'list':
        if (widget.attribute.value == 'bullet') {
          return Icons.format_list_bulleted;
        }
        return Icons.format_list_numbered;
      case 'code-block':
        return Icons.code;
      case 'blockquote':
        return Icons.format_quote;
      default:
        throw ArgumentError(
          'Could not find the icon for ${widget.attribute.toString()}',
        );
    }
  }

  IconData get iconData {
    return options.iconData ??
        context.requireQuillToolbarBaseButtonOptions.iconData ??
        _defaultIconData;
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
        options,
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
        iconTheme,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant QuillToolbarToggleStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = controller;
  }

  @override
  void dispose() {
    _controller.removeListener(_didChangeEditingValue);
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
    size: iconSize * kIconButtonFactor,
    icon: Icon(icon, size: iconSize, color: iconColor),
    fillColor: fill,
    onPressed: onPressed,
    afterPressed: afterPressed,
    borderRadius: iconTheme?.borderRadius ?? 2,
  );
}
