import 'package:flutter/widgets.dart';

import '../../controller/quill_controller.dart';
import '../../document/nodes/leaf.dart' as leaf;
import '../../document/nodes/leaf.dart';

abstract class EmbedBuilder {
  const EmbedBuilder();

  String get key;
  bool get expanded => true;

  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget);
  }

  String toPlainText(Embed node) => Embed.kObjectReplacementCharacter;

  Widget build(
    BuildContext context,
    QuillController controller,
    leaf.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  );
}

typedef EmbedsBuilder = EmbedBuilder Function(Embed node);
