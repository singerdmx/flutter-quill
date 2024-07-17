import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../document/attribute.dart';
import '../../../document/style.dart';
import '../../../l10n/extensions/localizations_ext.dart';
import '../../base_button/base_value_button.dart';
import '../../config/buttons/select_header_style_buttons_configurations.dart';
import '../../provider.dart';
import '../../simple_toolbar_provider.dart';
import '../quill_icon_button.dart';

typedef QuillToolbarSelectHeaderStyleBaseButtons = QuillToolbarBaseButton<
    QuillToolbarSelectHeaderStyleButtonsOptions,
    QuillToolbarSelectHeaderStyleButtonsExtraOptions>;

typedef QuillToolbarSelectHeaderStyleBaseButtonsState<
        W extends QuillToolbarSelectHeaderStyleBaseButtons>
    = QuillToolbarCommonButtonState<
        W,
        QuillToolbarSelectHeaderStyleButtonsOptions,
        QuillToolbarSelectHeaderStyleButtonsExtraOptions>;

class QuillToolbarSelectHeaderStyleButtons
    extends QuillToolbarSelectHeaderStyleBaseButtons {
  const QuillToolbarSelectHeaderStyleButtons({
    required super.controller,
    super.options = const QuillToolbarSelectHeaderStyleButtonsOptions(),
    super.key,
  });

  @override
  QuillToolbarSelectHeaderStyleButtonsState createState() =>
      QuillToolbarSelectHeaderStyleButtonsState();
}

class QuillToolbarSelectHeaderStyleButtonsState
    extends QuillToolbarSelectHeaderStyleBaseButtonsState {
  Attribute? _selectedAttribute;

  @override
  String get defaultTooltip => context.loc.headerStyle;

  @override
  IconData get defaultIconData => Icons.question_mark_outlined;

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

  List<Attribute> get _attributes {
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
      _attributes.every(
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

    final children = _attributes.map((attribute) {
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
                  'attribute',
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
