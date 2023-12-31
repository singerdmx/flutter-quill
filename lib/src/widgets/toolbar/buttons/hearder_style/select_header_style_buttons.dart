import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../extensions/quill_configurations_ext.dart';
import '../../../../l10n/extensions/localizations.dart';
import '../../../../models/documents/attribute.dart';
import '../../../../models/documents/style.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../quill/quill_controller.dart';
import '../../base_toolbar.dart';

class QuillToolbarSelectHeaderStyleButtons extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleButtons({
    required this.controller,
    this.options = const QuillToolbarSelectHeaderStyleButtonsOptions(),
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
    final baseFontSize = baseButtonExtraOptions?.iconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final baseIconFactor = baseButtonExtraOptions?.iconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        baseButtonExtraOptions?.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions {
    return context.quillToolbarBaseButtonOptions;
  }

  String get tooltip {
    return options.tooltip ??
        baseButtonExtraOptions?.tooltip ??
        context.loc.headerStyle;
  }

  Axis get axis {
    return options.axis ??
        context.quillSimpleToolbarConfigurations?.axis ??
        context.quillToolbarConfigurations?.axis ??
        Axis.horizontal;
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
        options.childBuilder ?? baseButtonExtraOptions?.childBuilder;

    final children = _attrbuites.map((attribute) {
      if (childBuilder != null) {
        return childBuilder(
          options,
          QuillToolbarSelectHeaderStyleButtonsExtraOptions(
            controller: controller,
            context: context,
            onPressed: () => _sharedOnPressed(attribute),
          ),
        );
      }

      final isSelected = _selectedAttribute == attribute;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: !kIsWeb ? 1.0 : 5.0),
        child: QuillToolbarIconButton(
          tooltip: tooltip,
          iconTheme: iconTheme,
          isSelected: isSelected,
          onPressed: () => _sharedOnPressed(attribute),
          icon: Text(
            _valueToText[attribute] ??
                (throw ArgumentError.notNull(
                  'attrbuite',
                )),
            style: style.copyWith(
              color: isSelected
                  ? iconTheme?.iconButtonSelectedData?.color
                  : iconTheme?.iconButtonUnselectedData?.color,
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
