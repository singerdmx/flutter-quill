import 'package:flutter/material.dart';

import '../../../common/structs/horizontal_spacing.dart';
import '../../../common/structs/vertical_spacing.dart';
import '../../../document/nodes/block.dart';
import '../../../document/nodes/leaf.dart';
import '../../../document/nodes/line.dart';
import '../../../document/nodes/node.dart';
import '../../embed/embed_editor_builder.dart';
import '../../widgets/cursor.dart';
import '../../widgets/link.dart';
import 'base_builder_configuration.dart';

typedef CheckBoxTapHandler = Function(int offset, bool value);
typedef LaunchURL = void Function(String);
typedef LinkActionPicker = Future<LinkMenuAction> Function(Node);
/// TODO: implement this configurations for block lines
class BlockBuilderConfiguration extends BuilderConfiguration<Block> {
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

class InlineBuilderConfiguration extends BuilderConfiguration<Line> {
  InlineBuilderConfiguration({
    required super.textDirection,
    required this.onLaunchUrl,
    required this.linkActionPicker,
    required this.embedBuilder,
    required super.node,
    required super.customRecognizerBuilder,
    required super.customStyleBuilder,
    required super.customLinkPrefixes,
    required super.readOnly,
    required super.styles,
    required this.devicePixelRatioOf,
  });
  final double devicePixelRatioOf;
  final LaunchURL? onLaunchUrl;
  final LinkActionPicker linkActionPicker;
  final EmbedBuilder Function(Embed) embedBuilder;
}
