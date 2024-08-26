import 'package:flutter/material.dart';

import '../../../common/structs/horizontal_spacing.dart';
import '../../../common/structs/vertical_spacing.dart';
import '../../../document/nodes/block.dart';
import '../../widgets/cursor.dart';
import 'config/base_builder_configuration.dart';

typedef CheckBoxTapHandler = Function(int offset, bool value);

/// TODO: implement this configurations for block lines
class BlockBuilderConfiguration extends BaseBuilderConfiguration<Block> {
  BlockBuilderConfiguration({
    required this.selectionColor,
    required this.verticalSpacing,
    required this.horizontalSpacing,
    required this.cursorCont,
    required this.indentLevelCounts,
    required this.clearIndents,
    required this.onCheckboxTap,
    required this.selection,
    required this.hasFocus,
    required this.enableInteractiveSelection,
    required this.checkBoxReadOnly,
    required super.textDirection,
    required super.node,
    required super.customRecognizerBuilder,
    required super.customStyleBuilder,
    required super.customLinkPrefixes,
    required super.readOnly,
    required super.styles,
  });
  final Color selectionColor;

  final VerticalSpacing verticalSpacing;
  final HorizontalSpacing horizontalSpacing;
  final CursorCont cursorCont;
  final Map<int, int> indentLevelCounts;
  final bool clearIndents;
  final CheckBoxTapHandler onCheckboxTap;
  final TextSelection selection;
  final bool hasFocus;
  final bool enableInteractiveSelection;
  final bool? checkBoxReadOnly;
}
