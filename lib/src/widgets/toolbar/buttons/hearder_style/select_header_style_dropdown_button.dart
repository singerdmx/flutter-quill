import 'package:flutter/material.dart';

import '../../../../../extensions.dart';
import '../../../../../translations.dart';
import '../../../../extensions/quill_configurations_ext.dart';
import '../../../../models/config/toolbar/base_button_configurations.dart';
import '../../../../models/config/toolbar/buttons/select_header_style_dropdown_button_configurations.dart';
import '../../../../models/documents/attribute.dart';
import '../../../../models/documents/style.dart';
import '../../../../models/themes/quill_icon_theme.dart';
import '../../../others/default_styles.dart';
import '../../../quill/quill_controller.dart';

class QuillToolbarSelectHeaderStyleDropdownButton extends StatefulWidget {
  const QuillToolbarSelectHeaderStyleDropdownButton({
    required this.controller,
    required this.options,
    super.key,
  });

  /// Since we can't get the state from the instace of the widget for comparing
  /// in [didUpdateWidget] then we will have to store reference here
  final QuillController controller;
  final QuillToolbarSelectHeaderStyleDropdownButtonOptions options;

  @override
  State<QuillToolbarSelectHeaderStyleDropdownButton> createState() =>
      _QuillToolbarSelectHeaderStyleDropdownButtonState();
}

class _QuillToolbarSelectHeaderStyleDropdownButtonState
    extends State<QuillToolbarSelectHeaderStyleDropdownButton> {
  Attribute? _selectedAttribute;

  Style get _selectionStyle => controller.getSelectionStyle();

  late final _valueToText = <Attribute, String>{
    Attribute.h1: context.loc.heading1,
    Attribute.h2: context.loc.heading2,
    Attribute.h3: context.loc.heading3,
    Attribute.h4: context.loc.heading4,
    Attribute.h5: context.loc.heading5,
    Attribute.h6: context.loc.heading6,
    Attribute.header: context.loc.normal,
  };

  Map<Attribute, TextStyle>? _headerTextStyles;

  QuillToolbarSelectHeaderStyleDropdownButtonOptions get options {
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

  List<Attribute> get _attrbuites {
    return options.attributes ?? _valueToText.keys.toList();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_headerTextStyles == null) {
      final defaultStyles = DefaultStyles.getInstance(context);
      _headerTextStyles = {
        Attribute.h1: defaultStyles.h1!.style,
        Attribute.h2: defaultStyles.h2!.style,
        Attribute.h3: defaultStyles.h3!.style,
        Attribute.h4: defaultStyles.h4!.style,
        Attribute.h5: defaultStyles.h5!.style,
        Attribute.h6: defaultStyles.h6!.style,
        Attribute.header:
            widget.options.style ?? defaultStyles.paragraph!.style,
      };
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_didChangeEditingValue);
    _selectedAttribute = _getHeaderValue();
  }

  @override
  Widget build(BuildContext context) {
    assert(_attrbuites.every((element) => _valueToText.keys.contains(element)));

    final baseButtonConfigurations =
        context.requireQuillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options.copyWith(
          iconSize: iconSize,
          iconTheme: iconTheme,
          tooltip: tooltip,
          afterButtonPressed: afterButtonPressed,
        ),
        QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions(
          currentValue: _selectedAttribute!,
          controller: controller,
          context: context,
          onPressed: _onPressed,
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        height: iconSize * 1.81,
        width: options.width,
      ),
      child: UtilityWidgets.maybeTooltip(
        message: tooltip,
        child: RawMaterialButton(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(iconTheme?.borderRadius ?? 2),
          ),
          fillColor: options.fillColor,
          elevation: 0,
          hoverElevation: options.hoverElevation,
          highlightElevation: options.hoverElevation,
          onPressed: _onPressed,
          child: _buildContent(context),
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

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final hasFinalWidth = options.width != null;
    return Padding(
      padding: options.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisSize: !hasFinalWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UtilityWidgets.maybeWidget(
            enabled: hasFinalWidth,
            wrapper: (child) => Expanded(child: child),
            child: Text(
              _valueToText[_selectedAttribute]!,
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                    color:
                        iconTheme?.iconUnselectedColor ?? theme.iconTheme.color,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize / 1.15,
            color: iconTheme?.iconUnselectedColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }

  void _onPressed() {
    _showMenu();
    options.afterButtonPressed?.call();
  }

  Future<void> _showMenu() async {
    final popupMenuTheme = PopupMenuTheme.of(context);
    final button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final newValue = await showMenu<Attribute>(
      context: context,
      elevation: 4,
      items: [
        for (final header in _valueToText.entries)
          PopupMenuItem<Attribute>(
            key: ValueKey(header.value),
            value: header.key,
            height: options.itemHeight ?? kMinInteractiveDimension,
            padding: options.itemPadding,
            child: Text(
              header.value,
              style: TextStyle(
                fontSize: options.renderItemTextStyle
                    ? _headerStyle(header.key).fontSize ??
                        DefaultTextStyle.of(context).style.fontSize ??
                        14
                    : null,
                color: header.key == _selectedAttribute
                    ? options.defaultItemColor
                    : null,
              ),
            ),
          ),
      ],
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    );
    if (newValue == null) {
      return;
    }

    final attribute0 =
        _selectedAttribute == newValue ? Attribute.header : newValue;
    controller.formatSelection(attribute0);
    afterButtonPressed?.call();
  }

  TextStyle _headerStyle(Attribute attribute) {
    assert(_headerTextStyles!.containsKey(attribute));
    return _headerTextStyles![attribute]!;
  }
}
