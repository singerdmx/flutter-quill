import 'package:flutter/material.dart';

import '../../../flutter_quill.dart'
    show QuillToolbarProvider, kDefaultToolbarSize;
import '../../l10n/widgets/localizations.dart';
import '../../models/config/toolbar/simple_toolbar_configurations.dart';
import '../../models/config/toolbar/toolbar_configurations.dart';
import 'simple_toolbar.dart';

export '../../models/config/toolbar/base_button_configurations.dart';
export '../../models/config/toolbar/simple_toolbar_configurations.dart';
export 'buttons/clear_format_button.dart';
export 'buttons/clipboard_button.dart';
export 'buttons/color/color_button.dart';
export 'buttons/custom_button_button.dart';
export 'buttons/font_family_button.dart';
export 'buttons/font_size_button.dart';
export 'buttons/hearder_style/select_header_style_buttons.dart';
export 'buttons/hearder_style/select_header_style_dropdown_button.dart';
export 'buttons/history_button.dart';
export 'buttons/indent_button.dart';
export 'buttons/link_style2_button.dart';
export 'buttons/link_style_button.dart';
export 'buttons/quill_icon_button.dart';
export 'buttons/search/search_button.dart';
export 'buttons/toggle_check_list_button.dart';
export 'buttons/toggle_style_button.dart';

typedef QuillBaseToolbarChildrenBuilder = List<Widget> Function(
  BuildContext context,
);

class QuillToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuillToolbar({
    required this.child,
    this.configurations = const QuillToolbarConfigurations(),
    super.key,
  });

  static QuillSimpleToolbar simple(
      {required QuillSimpleToolbarConfigurations configurations}) {
    return QuillSimpleToolbar(
      configurations: configurations,
    );
  }

  final Widget child;

  final QuillToolbarConfigurations configurations;

  // We can't get the modified [toolbarSize] by the developer
  // but we tested the [QuillToolbar] on the [appBar] and I didn't notice
  // a difference no matter what the value is so I will leave it to the
  // default
  @override
  Size get preferredSize => configurations.axis == Axis.horizontal
      ? const Size.fromHeight(kDefaultToolbarSize)
      : const Size.fromWidth(kDefaultToolbarSize);

  @override
  Widget build(BuildContext context) {
    return FlutterQuillLocalizationsWidget(
      child: QuillToolbarProvider(
        toolbarConfigurations: configurations,
        child: child,
      ),
    );
  }
}
