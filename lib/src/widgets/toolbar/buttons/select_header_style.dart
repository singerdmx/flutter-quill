import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../extensions.dart';
import '../../../extensions/quill_provider.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/documents/style.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../controller.dart';
import '../base_toolbar.dart';

class QuillToolbarSelectHeaderStyleButtons extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleButtons({
    required this.controller,
    required this.options,
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectHeaderStyleButtonsOptions options;

  @override
  QuillToolbarSelectHeaderStyleButtonsState createState() =>
      QuillToolbarSelectHeaderStyleButtonsState();
}

class QuillToolbarSelectHeaderStyleButtonsState
    extends State<QuillToolbarSelectHeaderStyleButtons> {
  Attribute? _selectedAttribute;

  Style get _selectionStyle => controller.getSelectionStyle();

  final _valueToText = <Attribute, String>{
    Attribute.header: 'N',
    Attribute.h1: 'H1',
    Attribute.h2: 'H2',
    Attribute.h3: 'H3',
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedAttribute = _getHeaderValue();
    });
    controller.addListener(_didChangeEditingValue);
  }

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

  void _sharedOnPressed(Attribute attribute) {
    final attribute0 =
        _selectedAttribute == attribute ? Attribute.header : attribute;
    controller.formatSelection(attribute0);
    afterButtonPressed?.call();
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

    final children = _attrbuites.map((attribute) {
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
      final theme = Theme.of(context);
      final isSelected = _selectedAttribute == attribute;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(
            width: iconSize * iconButtonFactor,
            height: iconSize * iconButtonFactor,
          ),
          child: UtilityWidgets.maybeTooltip(
            message: tooltip,
            child: RawMaterialButton(
              hoverElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(iconTheme?.borderRadius ?? 2)),
              fillColor: isSelected
                  ? (iconTheme?.iconSelectedFillColor ?? theme.primaryColor)
                  : (iconTheme?.iconUnselectedFillColor ?? theme.canvasColor),
              onPressed: () => _sharedOnPressed(attribute),
              child: Text(
                _valueToText[attribute] ??
                    (throw ArgumentError.notNull(
                      'attrbuite',
                    )),
                style: style.copyWith(
                  color: isSelected
                      ? (iconTheme?.iconSelectedColor ??
                          theme.primaryIconTheme.color)
                      : (iconTheme?.iconUnselectedColor ??
                          theme.iconTheme.color),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
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

  @override
  void didUpdateWidget(
      covariant QuillToolbarSelectHeaderStyleButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      controller.addListener(_didChangeEditingValue);
      _selectedAttribute = _getHeaderValue();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }
}
