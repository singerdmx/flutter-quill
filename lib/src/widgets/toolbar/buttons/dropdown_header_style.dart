import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';
import '../../../../translations.dart';

class QuillToolbarSelectHeaderStyleDropdownButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleDropdownButton({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectHeaderStyleButtonsOptions options;

  @override
  State<QuillToolbarSelectHeaderStyleDropdownButton> createState() =>
      _QuillToolbarSelectHeaderStyleDropdownButtonState();
}

class _QuillToolbarSelectHeaderStyleDropdownButtonState
    extends State<QuillToolbarSelectHeaderStyleDropdownButton> {
  Attribute? _selectedAttribute;

  Style get _selectionStyle => controller.getSelectionStyle();

  final _valueToText = <Attribute, String>{
    Attribute.header: 'N',
    Attribute.h1: 'H1',
    Attribute.h2: 'H2',
    Attribute.h3: 'H3',
  };

  QuillToolbarSelectHeaderStyleButtonsOptions get options {
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

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions.tooltip ??
        context.loc.headerStyle;
  }

  Axis get axis {
    return options.axis ??
        context.quillToolbarConfigurations?.axis ??
        context.quillBaseToolbarConfigurations?.axis ??
        (throw ArgumentError(
            'There is no default value for the Axis of the toolbar'));
  }

  List<Attribute> get _attrbuites {
    return options.attributes ??
        const [
          Attribute.header,
          Attribute.h1,
          Attribute.h2,
          Attribute.h3,
        ];
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(
      covariant QuillToolbarSelectHeaderStyleDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      controller.addListener(_didChangeEditingValue);
      _selectedAttribute = _getHeaderValue();
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
    controller.addListener(_didChangeEditingValue);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _attrbuites.every(
        (element) => _valueToText.keys.contains(element),
      ),
      'All attributes must be one of them: header, h1, h2 or h3',
    );

    final style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: iconSize * 0.7,
    );

    final childBuilder =
        options.childBuilder ?? baseButtonExtraOptions.childBuilder;

    for (final attribute in _attrbuites) {
      if (childBuilder != null) {
        return childBuilder(
          QuillToolbarSelectHeaderStyleButtonsOptions(
            afterButtonPressed: afterButtonPressed,
            attributes: _attrbuites,
            axis: axis,
            iconSize: iconSize,
            iconButtonFactor: iconButtonFactor,
            iconTheme: iconTheme,
            tooltip: tooltip,
          ),
          QuillToolbarSelectHeaderStyleButtonExtraOptions(
            controller: controller,
            context: context,
            onPressed: () => _sharedOnPressed(attribute),
          ),
        );
      }
    }

    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: iconSize * iconButtonFactor,
        height: iconSize * iconButtonFactor,
      ),
      child: Tooltip(
        message: tooltip,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Attribute>(
            value: _selectedAttribute,
            items: _valueToText.entries
                .map((header) => DropdownMenuItem(
                      value: header.key,
                      child: Text(
                        header.value,
                        style: style,
                      ),
                    ))
                .toList(),
            selectedItemBuilder: (context) =>
                _valueToText.entries.map((header) {
              final isSelected = _selectedAttribute == header.key;
              return Text(
                header.value,
                style: style.copyWith(
                  color: isSelected
                      ? (iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              );
            }).toList(),
            elevation: 0,
            borderRadius: BorderRadius.circular(iconTheme?.borderRadius ?? 2),
            padding:
                const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
            onChanged: (attribute) => _sharedOnPressed(attribute!),
          ),
        ),
      ),
    );
  }

  void _didChangeEditingValue() {
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
  }

  Attribute<dynamic> _getHeaderValue() {
    final attr = controller.toolbarButtonToggler[Attribute.header.key];
    if (attr != null) {
      // checkbox tapping causes controller.selection to go to offset 0
      controller.toolbarButtonToggler.remove(Attribute.header.key);
      return attr;
    }
    return _selectionStyle.attributes[Attribute.header.key] ?? Attribute.header;
  }

  void _sharedOnPressed(Attribute attribute) {
    final attribute0 =
        _selectedAttribute == attribute ? Attribute.header : attribute;
    controller.formatSelection(attribute0);
    afterButtonPressed?.call();
  }
}
