import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';

class QuillCustomButton {
  const QuillCustomButton(
      {this.icon,
      this.onTap,
      this.isToggled,
      this.builder = defaultCustomButtonBuilder});

  // The icon widget
  final IconData? icon;

  // The function when the icon is tapped
  final VoidCallback? onTap;

  // The function to determine whether the button is toggled
  final CustomButtonToggled? isToggled;

  // Can specify a custom builder to build the widget
  final CustomButtonBuilder builder;
}

class QuillCustomButtonWidget extends StatefulWidget {
  const QuillCustomButtonWidget(
      {required this.button,
      required this.controller,
      required this.iconSize,
      this.iconTheme,
      this.afterPressed});

  final QuillCustomButton button;
  final QuillController controller;
  final double iconSize;
  final QuillIconTheme? iconTheme;
  final VoidCallback? afterPressed;

  @override
  State<QuillCustomButtonWidget> createState() =>
      _QuillCustomButtonWidgetState();
}

class _QuillCustomButtonWidgetState extends State<QuillCustomButtonWidget> {
  bool _toggled = false;

  @override
  void initState() {
    super.initState();

    // set the initial toggled state
    _toggled =
        widget.button.isToggled != null ? widget.button.isToggled!() : false;

    // add listener to update the toggled state
    widget.controller.addListener(_didChangeEditingValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    final toggled =
        widget.button.isToggled != null ? widget.button.isToggled!() : false;

    if (toggled != _toggled) {
      setState(() {
        _toggled = toggled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.button.builder(
        context,
        widget.controller,
        widget.button.icon,
        widget.iconSize,
        widget.iconTheme,
        _toggled,
        widget.button.onTap,
        widget.afterPressed);
  }
}

typedef CustomButtonBuilder = Widget Function(
  BuildContext context,
  QuillController controller,
  IconData? icon,
  double iconSize,
  QuillIconTheme? iconTheme,
  bool isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed,
);

Widget defaultCustomButtonBuilder(
  BuildContext context,
  QuillController controller,
  IconData? icon,
  double iconSize,
  QuillIconTheme? iconTheme,
  bool isToggled,
  VoidCallback? onPressed,
  VoidCallback? afterPressed,
) {
  final theme = Theme.of(context);
  final isEnabled = onPressed != null;
  final iconColor = isEnabled
      ? isToggled
          ? (iconTheme?.iconSelectedColor ?? theme.primaryIconTheme.color)
          : (iconTheme?.iconUnselectedColor ?? theme.iconTheme.color)
      : (iconTheme?.disabledIconColor ?? theme.disabledColor);
  final fill = isEnabled
      ? isToggled
          ? (iconTheme?.iconSelectedFillColor ?? theme.toggleableActiveColor)
          : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor)
      : (iconTheme?.disabledIconFillColor ?? theme.canvasColor);

  return QuillIconButton(
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

typedef CustomButtonToggled = bool Function();
