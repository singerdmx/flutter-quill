import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

import '../../../flutter_quill.dart'
    show QuillBaseToolbarProvider, defaultToolbarSize;
import '../../models/config/toolbar/base_configurations.dart';
import '../../utils/extensions/build_context.dart';
import 'buttons/arrow_indicated_list.dart';

export '../../models/config/toolbar/buttons/base.dart';
export '../../models/config/toolbar/configurations.dart';
export 'buttons/clear_format.dart';
export 'buttons/color.dart';
export 'buttons/custom_button.dart';
export 'buttons/font_family.dart';
export 'buttons/font_size.dart';
export 'buttons/history.dart';
export 'buttons/indent.dart';
export 'buttons/link_style.dart';
export 'buttons/link_style2.dart';
export 'buttons/quill_icon.dart';
export 'buttons/search/search.dart';
export 'buttons/select_alignment.dart';
export 'buttons/select_header_style.dart';
export 'buttons/toggle_check_list.dart';
export 'buttons/toggle_style.dart';

typedef QuillBaseToolbarChildrenBuilder = List<Widget> Function(
  BuildContext context,
);

class QuillBaseToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuillBaseToolbar({
    required this.configurations,
    super.key,
  });

  final QuillBaseToolbarConfigurations configurations;

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
    final toolbarSize = configurations.toolbarSize;
    return I18n(
      initialLocale: context.quillSharedConfigurations?.locale,
      child: QuillBaseToolbarProvider(
        toolbarConfigurations: configurations,
        child: Builder(
          builder: (context) {
            if (configurations.multiRowsDisplay) {
              return Wrap(
                direction: configurations.axis,
                alignment: configurations.toolbarIconAlignment,
                crossAxisAlignment: configurations.toolbarIconCrossAlignment,
                runSpacing: 4,
                spacing: configurations.toolbarSectionSpacing,
                children: configurations.childrenBuilder(context),
              );
            }
            return Container(
              decoration: configurations.decoration ??
                  BoxDecoration(
                    color:
                        configurations.color ?? Theme.of(context).canvasColor,
                  ),
              constraints: BoxConstraints.tightFor(
                height:
                    configurations.axis == Axis.horizontal ? toolbarSize : null,
                width:
                    configurations.axis == Axis.vertical ? toolbarSize : null,
              ),
              child: QuillToolbarArrowIndicatedButtonList(
                axis: configurations.axis,
                buttons: configurations.childrenBuilder(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The divider which is used for separation of buttons in the toolbar.
///
/// It can be used outside of this package, for example when user does not use
/// [QuillBaseToolbar.basic] and compose toolbar's children on its own.
class QuillToolbarDivider extends StatelessWidget {
  const QuillToolbarDivider(
    this.axis, {
    super.key,
    this.color,
    this.space,
  });

  /// Provides a horizontal divider for vertical toolbar.
  const QuillToolbarDivider.horizontal({Color? color, double? space})
      : this(Axis.horizontal, color: color, space: space);

  /// Provides a horizontal divider for horizontal toolbar.
  const QuillToolbarDivider.vertical({Color? color, double? space})
      : this(Axis.vertical, color: color, space: space);

  /// The axis along which the toolbar is.
  final Axis axis;

  /// The color to use when painting this divider's line.
  final Color? color;

  /// The divider's space (width or height) depending of [axis].
  final double? space;

  @override
  Widget build(BuildContext context) {
    // Vertical toolbar requires horizontal divider, and vice versa
    return axis == Axis.vertical
        ? Divider(
            height: space,
            color: color,
            indent: 12,
            endIndent: 12,
          )
        : VerticalDivider(
            width: space,
            color: color,
            indent: 12,
            endIndent: 12,
          );
  }
}
