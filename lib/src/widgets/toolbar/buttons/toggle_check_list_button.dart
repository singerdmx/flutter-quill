import 'package:flutter/material.dart';

import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../utils/widgets.dart';
import '../base_button/stateful_base_button_ex.dart';
import '../base_toolbar.dart';

class QuillToolbarToggleCheckListButton extends QuillToolbarStatefulBaseButton<
    QuillToolbarToggleCheckListButtonOptions,
    QuillToolbarToggleCheckListButtonExtraOptions> {
  const QuillToolbarToggleCheckListButton({
    required super.controller,
    super.options = const QuillToolbarToggleCheckListButtonOptions(),
    super.key,
  });

  @override
  QuillToolbarToggleCheckListButtonState createState() =>
      QuillToolbarToggleCheckListButtonState();
}

class QuillToolbarToggleCheckListButtonState
    extends QuillToolbarBaseButtonState<
        QuillToolbarToggleCheckListButton,
        QuillToolbarToggleCheckListButtonOptions,
        QuillToolbarToggleCheckListButtonExtraOptions> {
  bool? _isToggled;

  Style get _selectionStyle => controller.getSelectionStyle();

  @override
  void didChangeEditingValue() {
    setState(() {
      _isToggled = _getIsToggled(controller.getSelectionStyle().attributes);
    });
  }

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
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
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  String get defaultTooltip => context.loc.checkedList;

  IconData get iconData {
    return options.iconData ??
        baseButtonExtraOptions?.iconData ??
        Icons.check_box;
  }

  @override
  Widget build(BuildContext context) {
    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options,
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
