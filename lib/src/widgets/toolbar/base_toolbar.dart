import 'package:flutter/material.dart';

import '../../../flutter_quill.dart'
    show QuillBaseToolbarProvider, defaultToolbarSize;
import '../../l10n/widgets/localizations.dart';
import '../../models/config/toolbar/simple_toolbar_configurations.dart';
import '../../models/config/toolbar/toolbar_configurations.dart';
import 'simple_toolbar.dart';

export '../../models/config/toolbar/buttons/base_configurations.dart';
export '../../models/config/toolbar/simple_toolbar_configurations.dart';
export 'buttons/clear_format_button.dart';
export 'buttons/color/color_button.dart';
export 'buttons/custom_button_button.dart';
export 'buttons/font_family_button.dart';
export 'buttons/font_size_button.dart';
export 'buttons/history_button.dart';
export 'buttons/indent_button.dart';
export 'buttons/link_style2_button.dart';
export 'buttons/link_style_button.dart';
export 'buttons/quill_icon_button.dart';
export 'buttons/search/search_button.dart';
export 'buttons/select_header_style_buttons.dart';
export 'buttons/toggle_check_list_button.dart';
export 'buttons/toggle_style_button.dart';

typedef QuillBaseToolbarChildrenBuilder = List<Widget> Function(
  BuildContext context,
);

class QuillToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuillToolbar({
    required this.configurations,
    super.key,
  });

  static QuillSimpleToolbar simple(
      QuillSimpleToolbarConfigurations configurations) {
    return QuillSimpleToolbar(
      configurations: configurations,
    );
  }

  final QuillToolbarConfigurations configurations;

  // We can't get the modified [toolbarSize] by the developer
  // but we tested the [QuillToolbar] on the [appBar] and I didn't notice
  // a difference no matter what the value is so I will leave it to the
  // default
  @override
  Size get preferredSize => configurations.axis == Axis.horizontal
      ? const Size.fromHeight(defaultToolbarSize)
      : const Size.fromWidth(defaultToolbarSize);

  @override
  Widget build(BuildContext context) {
    return FlutterQuillLocalizationsWidget(
      child: QuillBaseToolbarProvider(
        toolbarConfigurations: configurations,
        child: configurations.child,
      ),
    );
  }
}
