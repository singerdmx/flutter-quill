import 'package:flutter/material.dart';

import '../../../l10n/extensions/localizations_ext.dart';
import '../../base_button/stateless_base_button.dart';
import '../../simple_toolbar.dart';

class QuillToolbarSearchButton extends QuillToolbarBaseButtonStateless {
  const QuillToolbarSearchButton({
    required super.controller,
    QuillToolbarSearchButtonOptions? options,

    /// Shares common options between all buttons, prefer the [options]
    /// over the [baseOptions].
    super.baseOptions,
    super.key,
  })  : _options = options,
        super(options: options);

  final QuillToolbarSearchButtonOptions? _options;

  @override
  QuillToolbarSearchButtonOptions? get options => _options;

  Future<void> _sharedOnPressed(BuildContext context) async {
    final customCallback = options?.customOnPressedCallback;
    if (customCallback != null) {
      await customCallback(
        controller,
      );
      return;
    }
    await showDialog<String>(
      context: context,
      builder: (_) => QuillToolbarSearchDialog(
        controller: controller,
        dialogTheme: options?.dialogTheme,
        searchBarAlignment: options?.searchBarAlignment,
      ),
    );
  }

  @override
  Widget buildButton(BuildContext context) {
    return QuillToolbarIconButton(
      tooltip: tooltip(context),
      icon: Icon(
        iconData(context),
        size: iconSize(context) * iconButtonFactor(context),
      ),
      isSelected: false,
      onPressed: () => _sharedOnPressed(context),
      afterPressed: afterButtonPressed(context),
      iconTheme: iconTheme(context),
    );
  }

  @override
  Widget? buildCustomChildBuilder(BuildContext context) {
    return childBuilder?.call(
      options,
      QuillToolbarSearchButtonExtraOptions(
        controller: controller,
        context: context,
        onPressed: () {
          _sharedOnPressed(context);
          afterButtonPressed.call(context);
        },
      ),
    );
  }

  @override
  IconData Function(BuildContext context) get getDefaultIconData =>
      (context) => Icons.search;

  @override
  String Function(BuildContext context) get getDefaultTooltip =>
      (context) => context.loc.search;
}
