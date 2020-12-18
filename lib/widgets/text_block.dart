import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/nodes/block.dart';
import 'package:tuple/tuple.dart';

import 'delegate.dart';

class EditableTextBlock extends StatelessWidget {
  final Block block;
  final TextDirection textDirection;
  final Tuple2 verticalSpacing;
  final TextSelection textSelection;
  final Color color;
  final bool enableInteractiveSelection;
  final bool hasFocus;
  final EdgeInsets contentPadding;
  final EmbedBuilder embedBuilder;

  EditableTextBlock(
      this.block,
      this.textDirection,
      this.verticalSpacing,
      this.textSelection,
      this.color,
      this.enableInteractiveSelection,
      this.hasFocus,
      this.contentPadding,
      this.embedBuilder)
      : assert(hasFocus != null),
        assert(embedBuilder != null);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

//class RenderEditableTextBlock extends RenderEditableContainerBox
//    implements RenderEditableBox {
//
//    }
