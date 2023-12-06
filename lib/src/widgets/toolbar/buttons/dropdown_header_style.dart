import 'package:flutter/material.dart';

import '../../../../flutter_quill.dart';
import '../../../../translations.dart';
import '../../../utils/widgets.dart';

class QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions
    extends QuillToolbarBaseButtonExtraOptions {
  const QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions({
    required this.currentValue,
    required super.controller,
    required super.context,
    required super.onPressed,
  });
  final Attribute currentValue;
}

class QuillToolbarSelectHeaderStyleDropdownButtonOptions
    extends QuillToolbarBaseButtonOptions<
        QuillToolbarSelectHeaderStyleDropdownButtonOptions,
        QuillToolbarSelectHeaderStyleDropdownButtonExtraOptions> {
  const QuillToolbarSelectHeaderStyleDropdownButtonOptions({
    super.controller,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
    this.iconSize,
    this.iconButtonFactor,
    this.fillColor,
    this.hoverElevation = 1,
    this.highlightElevation = 1,
    this.rawItemsMap,
    this.onSelected,
    this.attributes,
    this.padding,
    this.style,
    this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor,
  });

  final double? iconSize;
  final double? iconButtonFactor;
  final Color? fillColor;
  final double hoverElevation;
  final double highlightElevation;
  final Map<String, String>? rawItemsMap;
  final ValueChanged<String>? onSelected;
  final List<Attribute>? attributes;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final String? initialValue;
  final TextOverflow labelOverflow;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;

  QuillToolbarSelectHeaderStyleDropdownButtonOptions copyWith({
    Color? fillColor,
    double? hoverElevation,
    double? highlightElevation,
    List<PopupMenuEntry<String>>? items,
    Map<String, String>? rawItemsMap,
    ValueChanged<String>? onSelected,
    List<Attribute>? attributes,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
    double? width,
    String? initialValue,
    TextOverflow? labelOverflow,
    bool? renderFontFamilies,
    bool? overrideTooltipByFontFamily,
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    double? iconSize,
    double? iconButtonFactor,
    // Add properties to override inherited properties
    QuillController? controller,
    IconData? iconData,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    QuillIconTheme? iconTheme,
  }) {
    return QuillToolbarSelectHeaderStyleDropdownButtonOptions(
      attributes: attributes ?? this.attributes,
      rawItemsMap: rawItemsMap ?? this.rawItemsMap,
      controller: controller ?? this.controller,
      iconData: iconData ?? this.iconData,
      afterButtonPressed: afterButtonPressed ?? this.afterButtonPressed,
      tooltip: tooltip ?? this.tooltip,
      iconTheme: iconTheme ?? this.iconTheme,
      onSelected: onSelected ?? this.onSelected,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      width: width ?? this.width,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      itemHeight: itemHeight ?? this.itemHeight,
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      fillColor: fillColor ?? this.fillColor,
      hoverElevation: hoverElevation ?? this.hoverElevation,
      highlightElevation: highlightElevation ?? this.highlightElevation,
    );
  }
}

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

  final _valueToText = <Attribute, String>{
    Attribute.header: 'Normal',
    Attribute.h1: 'H1',
    Attribute.h2: 'H2',
    Attribute.h3: 'H3',
  };

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
    _selectedAttribute = _getHeaderValue();
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
              _selectedAttribute!.key,
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
                color: header.value == 'N' ? options.defaultItemColor : null,
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
}
