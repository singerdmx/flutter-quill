import 'package:flutter/widgets.dart';

import '../../document/nodes/leaf.dart' as leaf;
import 'embed_context.dart';

export './embed_context.dart';

abstract class EmbedBuilder {
  const EmbedBuilder();

  String get key;
  bool get expanded => true;

  /// The character length this embed occupies in the text sent to the platform.
  ///
  /// Defaults to `1` (the single object-replacement character `\uFFFC`).
  /// Override this together with [toPlainText] to return a value matching
  /// the length of the plain-text representation so that the OS keyboard
  /// can correctly detect word and sentence boundaries around the embed
  /// (e.g. for [TextCapitalization.sentences]).
  int get length => 1;

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
