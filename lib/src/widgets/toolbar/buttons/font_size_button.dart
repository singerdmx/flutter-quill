import 'package:flutter/material.dart';

import '../../../../extensions.dart';

import '../../../extensions/quill_configurations_ext.dart';
import '../../../l10n/extensions/localizations.dart';
import '../../../models/documents/attribute.dart';
import '../../../models/themes/quill_icon_theme.dart';
import '../../../utils/font.dart';
import '../../quill/quill_controller.dart';
import '../base_toolbar.dart';

class QuillToolbarFontSizeButton extends StatefulWidget {
  QuillToolbarFontSizeButton({
    required this.controller,
    required this.defaultDisplayText,
    this.options = const QuillToolbarFontSizeButtonOptions(),
    super.key,
  })  : assert(options.rawItemsMap?.isNotEmpty ?? true),
        assert(options.initialValue == null ||
            (options.initialValue?.isNotEmpty ?? true));

  final QuillToolbarFontSizeButtonOptions options;

  final String defaultDisplayText;

  /// Since we can't get the state from the instace of the widget for comparing
  /// in [didUpdateWidget] then we will have to store reference here
  final QuillController controller;

  @override
  QuillToolbarFontSizeButtonState createState() =>
      QuillToolbarFontSizeButtonState();
}

class QuillToolbarFontSizeButtonState
    extends State<QuillToolbarFontSizeButton> {
  String _currentValue = '';

  QuillToolbarFontSizeButtonOptions get options {
    return widget.options;
  }

  Map<String, String> get rawItemsMap {
    final fontSizes = options.rawItemsMap ??
        context.quillSimpleToolbarConfigurations?.fontSizesValues ??
        {
          context.loc.small: 'small',
          context.loc.large: 'large',
          context.loc.huge: 'huge',
          context.loc.clear: '0'
        };
    return fontSizes;
  }

  String? getLabel(String? currentValue) {
    return switch (currentValue) {
      'small' => context.loc.small,
      'large' => context.loc.large,
      'huge' => context.loc.huge,
      String() => currentValue,
      null => null,
    };
  }

  String get _defaultDisplayText {
    return options.initialValue ?? widget.defaultDisplayText;
  }

  @override
  void initState() {
    super.initState();
    _currentValue = _defaultDisplayText;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _getKeyName(dynamic value) {
    for (final entry in rawItemsMap.entries) {
      if (getFontSize(entry.value) == getFontSize(value)) {
        return entry.key;
      }
    }
    return null;
  }

  QuillController get controller {
    return widget.controller;
  }

  double get iconSize {
    final baseFontSize = context.quillToolbarBaseButtonOptions?.globalIconSize;
    final iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final baseIconFactor =
        context.quillToolbarBaseButtonOptions?.globalIconButtonFactor;
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kIconButtonFactor;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ??
        context.quillToolbarBaseButtonOptions?.afterButtonPressed;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ??
        context.quillToolbarBaseButtonOptions?.iconTheme;
  }

  String get tooltip {
    return options.tooltip ??
        context.quillToolbarBaseButtonOptions?.tooltip ??
        context.loc.fontSize;
  }

  void _onPressed() {
    _showMenu();
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final baseButtonConfigurations = context.quillToolbarBaseButtonOptions;
    final childBuilder =
        options.childBuilder ?? baseButtonConfigurations?.childBuilder;
    if (childBuilder != null) {
      return childBuilder(
        options.copyWith(
          tooltip: tooltip,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          afterButtonPressed: afterButtonPressed,
        ),
        QuillToolbarFontSizeButtonExtraOptions(
          controller: controller,
          currentValue: _currentValue,
          defaultDisplayText: _defaultDisplayText,
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
      child: Builder(
        builder: (context) {
          final isMaterial3 = Theme.of(context).useMaterial3;
          if (!isMaterial3) {
            return RawMaterialButton(
              onPressed: _onPressed,
              child: _buildContent(context),
            );
          }
          return QuillToolbarIconButton(
            tooltip: tooltip,
            isSelected: false,
            iconTheme: iconTheme?.copyWith(
              iconButtonSelectedData: const IconButtonData(
                visualDensity: VisualDensity.compact,
              ),
              iconButtonUnselectedData: const IconButtonData(
                visualDensity: VisualDensity.compact,
              ),
            ),
            onPressed: _onPressed,
            icon: _buildContent(context),
          );
        },
      ),
    );
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
    final newValue = await showMenu<String>(
      context: context,
      elevation: 4,
      items: [
        for (final MapEntry<String, String> fontSize in rawItemsMap.entries)
          PopupMenuItem<String>(
            key: ValueKey(fontSize.key),
            value: fontSize.value,
            height: options.itemHeight ?? kMinInteractiveDimension,
            padding: options.itemPadding,
            onTap: () {
              if (fontSize.value == '0') {
                controller.selectFontSize(null);
                return;
              }
              controller.selectFontSize(fontSize.value);
            },
            child: Text(
              fontSize.key.toString(),
              style: TextStyle(
                color: fontSize.value == '0' ? options.defaultItemColor : null,
              ),
            ),
          ),
      ],
      position: position,
      shape: popupMenuTheme.shape,
      color: popupMenuTheme.color,
    );
    if (!mounted) return;
    if (newValue == null) {
      return;
    }
    final keyName = _getKeyName(newValue);
    setState(() {
      if (keyName != 'Clear') {
        _currentValue = keyName ?? _defaultDisplayText;
      } else {
        _currentValue = _defaultDisplayText;
      }
      if (keyName != null) {
        controller.formatSelection(
          Attribute.fromKeyValue(
            Attribute.size.key,
            newValue == '0' ? null : getFontSize(newValue),
          ),
        );
        options.onSelected?.call(newValue);
      }
    });
  }

  Widget _buildContent(BuildContext context) {
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
              getLabel(widget.controller.selectedFontSize) ??
                  getLabel(_currentValue) ??
                  '',
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                    // color: iconTheme?.iconUnselectedFillColor ??
                    //     theme.iconTheme.color,
                  ),
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize / 1.15,
            // color: iconTheme?.iconUnselectedFillColor ?? theme.iconTheme.color,
          )
        ],
      ),
    );
  }
}
