import 'package:flutter/widgets.dart';

import '../../document/nodes/leaf.dart' as leaf;
import 'embed_context.dart';

export './embed_context.dart';

abstract class EmbedBuilder {
  const EmbedBuilder();

  String get key;
  bool get expanded => true;

  WidgetSpan buildWidgetSpan(Widget widget) {
    return WidgetSpan(child: widget);
  }

  String toPlainText(leaf.Embed node) => leaf.Embed.kObjectReplacementCharacter;

  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  );
}

typedef EmbedsBuilder = EmbedBuilder Function(leaf.Embed node);
