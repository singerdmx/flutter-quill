import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart'
    show Axis, Color, Decoration, WrapAlignment, WrapCrossAlignment, immutable;

import '../../../widgets/toolbar/base_toolbar.dart';
import '../../structs/link_dialog_action.dart';

@immutable
class QuillBaseToolbarConfigurations extends Equatable {
  const QuillBaseToolbarConfigurations({
    required this.childrenBuilder,
    this.axis = Axis.horizontal,
    this.toolbarSize = kDefaultIconSize * 2,
    this.toolbarSectionSpacing = kToolbarSectionSpacing,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    this.color,
    this.customButtons = const [],
    this.sectionDividerColor,
    this.sectionDividerSpace,
    this.linkDialogAction,
    this.multiRowsDisplay = true,
    this.decoration,
  });

  final QuillBaseToolbarChildrenBuilder childrenBuilder;
  final Axis axis;
  final double toolbarSectionSpacing;
  final WrapAlignment toolbarIconAlignment;
  final WrapCrossAlignment toolbarIconCrossAlignment;
  final double toolbarSize;

  // Overrides the action in the _LinkDialog widget
  final LinkDialogAction? linkDialogAction;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

  /// List of custom buttons
  final List<QuillToolbarCustomButtonOptions> customButtons;

  /// The color to use when painting the toolbar section divider.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  final Color? sectionDividerColor;

  /// The space occupied by toolbar section divider.
  final double? sectionDividerSpace;

  /// If you want the toolbar to not be a multiple rows pass false
  final bool multiRowsDisplay;

  /// The decoration to use for the toolbar.
  final Decoration? decoration;

  @override
  List<Object?> get props => [];
}
