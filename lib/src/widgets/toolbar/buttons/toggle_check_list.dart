import 'package:flutter/material.dart';

import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/config/toolbar/buttons/base.dart';
import '../../../models/config/toolbar/buttons/toggle_check_list.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/widgets.dart';
import '../../controller.dart';
import 'toggle_style.dart';

class QuillToolbarToggleCheckListButton extends StatefulWidget {
  const QuillToolbarToggleCheckListButton({
    required this.options,
    required this.controller,
    super.key,
  });

  final QuillToolbarToggleCheckListButtonOptions options;

  final QuillController controller;

  @override
  QuillToolbarToggleCheckListButtonState createState() =>
      QuillToolbarToggleCheckListButtonState();
}

class QuillToolbarToggleCheckListButtonState
    extends State<QuillToolbarToggleCheckListButton> {
  bool? _isToggled;

  Style get _selectionStyle => controller.getSelectionStyle();

  void _didChangeEditingValue() {
    setState(() {
      _isToggled = _getIsToggled(controller.getSelectionStyle().attributes);
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    controller.addListener(_didChangeEditingValue);
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    var attribute = controller.toolbarButtonToggler[Attribute.list.key];

    if (attribute == null) {
      attribute = attrs[Attribute.list.key];
    } else {
      // checkbox tapping causes controller.selection to go to offset 0
      controller.toolbarButtonToggler.remove(Attribute.list.key);
    }

    if (attribute == null) {
      return false;
    }
    return attribute.value == Attribute.unchecked.value ||
        attribute.value == Attribute.checked.value;
  }

  @override
  void didUpdateWidget(covariant QuillToolbarToggleCheckListButton oldWidget) {
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

  QuillToolbarToggleCheckListButtonOptions get options {
    return widget.options;
  }

  QuillController get controller {
    return widget.controller;
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

  IconData get iconData {
    return options.iconData ??
        baseButtonExtraOptions.iconData ??
        Icons.check_box;
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        context.loc.checkedList;
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarToggleCheckListButtonOptions(
          afterButtonPressed: afterButtonPressed,
          iconTheme: iconTheme,
          controller: controller,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          tooltip: tooltip,
          iconData: iconData,
        ),
        QuillToolbarToggleCheckListButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () {
            _toggleAttribute();
            afterButtonPressed?.call();
          },
          isToggled: _isToggled ?? false,
        ),
      );
    }
    return UtilityWidgets.maybeTooltip(
      message: tooltip,
      child: defaultToggleStyleButtonBuilder(
        context,
        Attribute.unchecked,
        iconData,
        options.fillColor,
        _isToggled,
        _toggleAttribute,
        afterButtonPressed,
        iconSize,
        iconButtonFactor,
        iconTheme,
      ),
    );
  }

  void _toggleAttribute() {
    controller
      ..skipRequestKeyboard = !options.isShouldRequestKeyboard
      ..formatSelection(
        _isToggled!
            ? Attribute.clone(Attribute.unchecked, null)
            : Attribute.unchecked,
      );
  }
}
