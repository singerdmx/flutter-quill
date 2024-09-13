import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart'
    show Axis, Color, Decoration, WrapAlignment, WrapCrossAlignment;

import '../../editor_toolbar_shared/config/quill_shared_configurations.dart';
import '../base_toolbar.dart';
import '../structs/link_dialog_action.dart';

abstract class QuillSharedToolbarProperties extends Equatable {
  const QuillSharedToolbarProperties({
    this.sharedConfigurations = const QuillSharedConfigurations(),
    this.toolbarSize,
    this.axis = Axis.horizontal,
    this.toolbarIconAlignment = WrapAlignment.center,
    this.toolbarIconCrossAlignment = WrapCrossAlignment.center,
    this.toolbarSectionSpacing = kToolbarSectionSpacing,
    this.color,
    this.sectionDividerColor,
    this.sectionDividerSpace,
    this.linkDialogAction,
    this.multiRowsDisplay = true,
    this.decoration,
    this.buttonOptions = const QuillSimpleToolbarButtonOptions(),
    this.toolbarRunSpacing = 4,
  });
  final Axis axis;

  final WrapAlignment toolbarIconAlignment;
  final WrapCrossAlignment toolbarIconCrossAlignment;
  final double toolbarRunSpacing;
  final double? toolbarSize;

  /// Only works if [multiRowsDisplay] is `true`
  final double toolbarSectionSpacing;

  // Overrides the action in the _LinkDialog widget
  final LinkDialogAction? linkDialogAction;

  /// The color of the toolbar.
  ///
  /// Defaults to [ThemeData.canvasColor] of the current [Theme] if no color
  /// is given.
  final Color? color;

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

  /// If you want change spesefic buttons or all of them
  /// then you came to the right place
  final QuillSimpleToolbarButtonOptions buttonOptions;

  final QuillSharedConfigurations sharedConfigurations;
}
