import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/internal.dart';

import 'package:meta/meta.dart';

import '../../common/utils/quill_table_utils.dart';
import 'models/table_config.dart';

@experimental
@Deprecated(
    'QuillToolbarTableButton will no longer used and will be removed in future releases')
class QuillToolbarTableButton extends StatelessWidget {
  const QuillToolbarTableButton({
    required this.controller,
    this.options = const QuillToolbarTableButtonOptions(),
    super.key,
  });

  final QuillController controller;

  final QuillToolbarTableButtonOptions options;

  double _iconSize(BuildContext context) {
    final iconSize = options.iconSize;
    return iconSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ?? Icons.table_chart;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ?? context.loc.insertTable;
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(context);
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconButtonFactor = _iconButtonFactor(context);
    final iconData = _iconData(context);
    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      return childBuilder(
        QuillToolbarTableButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: iconData,
          iconSize: iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: options.iconTheme,
          tooltip: options.tooltip,
        ),
        QuillToolbarTableButtonExtraOptions(
          context: context,
          controller: controller,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconButtonFactor * iconSize,
      ),
      tooltip: tooltip,
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      iconTheme: _iconTheme(context),
    );
  }

  Future<void> _onPressedHandler(BuildContext context) async {
    final position = renderPosition(context);
    await showMenu(context: context, position: position, items: [
      const PopupMenuItem(value: 2, child: Text('2x2')),
      const PopupMenuItem(value: 4, child: Text('4x4')),
      const PopupMenuItem(value: 6, child: Text('6x6')),
    ]).then(
      (value) {
        if (value != null) {
          insertTable(value, value, controller, ChangeSource.local);
        }
      },
    );
  }
}
