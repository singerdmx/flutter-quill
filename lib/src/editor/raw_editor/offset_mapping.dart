import 'package:flutter/services.dart' show TextSelection, TextRange;

import '../../../quill_delta.dart';
import '../../document/nodes/embeddable.dart';
import '../../document/nodes/leaf.dart';
import '../embed/embed_editor_builder.dart';

/// Records the position and expanded length of a single embed
/// whose `toPlainText()` returns a string longer than 1 character.
class EmbedSpan {
  const EmbedSpan({
    required this.docOffset,
    required this.expandedOffset,
    required this.expandedLength,
  });

  /// Offset of this embed in the document model (where it is length 1).
  final int docOffset;

  /// Offset of this embed in the expanded text.
  final int expandedOffset;

  /// Length of the embed's text in expanded form.
  final int expandedLength;
}

/// Bidirectional mapping between document offsets (where embeds are length 1)
/// and expanded-text offsets (where embeds use their `toPlainText()` length).
///
/// Used exclusively at the platform text-input boundary so that the OS
/// keyboard sees real text for sentence/word boundary detection.
class OffsetMapping {
  OffsetMapping._({
    required this.expandedText,
    required List<EmbedSpan> embeds,
  }) : _embeds = embeds;

  /// The plain text with embeds expanded to their `toPlainText()` value.
  final String expandedText;

  /// Embed spans sorted by [EmbedSpan.docOffset].
  final List<EmbedSpan> _embeds;

  /// Convert a document offset to the corresponding expanded-text offset.
  int docToExpanded(int docOffset) {
    var shift = 0;
    for (final embed in _embeds) {
      if (embed.docOffset < docOffset) {
        shift += embed.expandedLength - 1;
      } else {
        break;
      }
    }
    return docOffset + shift;
  }

  /// Convert an expanded-text offset to a document offset.
  ///
  /// If the offset falls inside an embed's expanded text, snaps to the
  /// nearest boundary (start or end of the embed in document space).
  int expandedToDoc(int expandedOffset) {
    var shift = 0;
    for (final embed in _embeds) {
      final embedStart = embed.expandedOffset;
      final embedEnd = embed.expandedOffset + embed.expandedLength;

      if (expandedOffset <= embedStart) {
        break;
      } else if (expandedOffset < embedEnd) {
        // Inside the embed — snap to nearest boundary.
        final distToStart = expandedOffset - embedStart;
        final distToEnd = embedEnd - expandedOffset;
        if (distToStart <= distToEnd) {
          return embed.docOffset; // before embed
        } else {
          return embed.docOffset + 1; // after embed
        }
      } else {
        shift += embed.expandedLength - 1;
      }
    }
    return expandedOffset - shift;
  }

  /// Convert an expanded-text offset to a document offset.
  ///
  /// If the offset falls inside an embed's expanded text, snaps to the
  /// **start** of the embed in document space.
  /// Use this for the start of a deletion range.
  int expandedToDocFloor(int expandedOffset) {
    var shift = 0;
    for (final embed in _embeds) {
      final embedStart = embed.expandedOffset;
      final embedEnd = embed.expandedOffset + embed.expandedLength;

      if (expandedOffset <= embedStart) {
        break;
      } else if (expandedOffset < embedEnd) {
        return embed.docOffset;
      } else {
        shift += embed.expandedLength - 1;
      }
    }
    return expandedOffset - shift;
  }

  /// Convert an expanded-text offset to a document offset.
  ///
  /// If the offset falls inside an embed's expanded text, snaps to the
  /// **end** (one past) the embed in document space.
  /// Use this for the end of a deletion range.
  int expandedToDocCeil(int expandedOffset) {
    var shift = 0;
    for (final embed in _embeds) {
      final embedStart = embed.expandedOffset;
      final embedEnd = embed.expandedOffset + embed.expandedLength;

      if (expandedOffset <= embedStart) {
        break;
      } else if (expandedOffset <= embedEnd) {
        // At or inside the embed — snap to after the embed.
        return embed.docOffset + 1;
      } else {
        shift += embed.expandedLength - 1;
      }
    }
    return expandedOffset - shift;
  }

  /// Convert a document-space [TextSelection] to expanded-text space.
  TextSelection docToExpandedSelection(TextSelection selection) {
    return selection.copyWith(
      baseOffset: docToExpanded(selection.baseOffset),
      extentOffset: docToExpanded(selection.extentOffset),
    );
  }

  /// Convert an expanded-text-space [TextSelection] to document space.
  TextSelection expandedToDocSelection(TextSelection selection) {
    return selection.copyWith(
      baseOffset: expandedToDoc(selection.baseOffset),
      extentOffset: expandedToDoc(selection.extentOffset),
    );
  }

  /// Convert an expanded-text-space [TextRange] to document space.
  TextRange expandedToDocRange(TextRange range) {
    return TextRange(
      start: expandedToDoc(range.start),
      end: expandedToDoc(range.end),
    );
  }
}

/// Build an [OffsetMapping] by walking the document [delta].
///
/// For each embed operation, looks up the matching [EmbedBuilder] from
/// [embedBuilders] (or [unknownEmbedBuilder]) and calls `toPlainText()`.
/// If the expanded text differs from the single-character default, an
/// [EmbedSpan] is recorded.
OffsetMapping buildOffsetMapping(
  Delta delta,
  Iterable<EmbedBuilder>? embedBuilders,
  EmbedBuilder? unknownEmbedBuilder,
) {
  final buffer = StringBuffer();
  final embeds = <EmbedSpan>[];
  var docOffset = 0;
  var expandedOffset = 0;

  for (final op in delta.toList()) {
    if (!op.isInsert) continue;

    if (op.data is Map) {
      // Embed operation.
      final embeddable =
          Embeddable.fromJson(Map<String, dynamic>.from(op.data as Map));
      final embedText = _getEmbedPlainText(
        embeddable,
        embedBuilders,
        unknownEmbedBuilder,
      );

      buffer.write(embedText);

      if (embedText.length != 1 ||
          embedText != Embed.kObjectReplacementCharacter) {
        embeds.add(EmbedSpan(
          docOffset: docOffset,
          expandedOffset: expandedOffset,
          expandedLength: embedText.length,
        ));
      }

      docOffset += 1; // always 1 in document/delta
      expandedOffset += embedText.length;
    } else {
      // Text operation.
      final text = op.data as String;
      buffer.write(text);
      docOffset += text.length;
      expandedOffset += text.length;
    }
  }

  return OffsetMapping._(
    expandedText: buffer.toString(),
    embeds: embeds,
  );
}

/// Look up the matching [EmbedBuilder] for [embeddable] and call
/// `toPlainText()`. Falls back to [unknownEmbedBuilder] or `\uFFFC`.
String _getEmbedPlainText(
  Embeddable embeddable,
  Iterable<EmbedBuilder>? embedBuilders,
  EmbedBuilder? unknownEmbedBuilder,
) {
  final embedNode = Embed(embeddable);

  if (embedBuilders != null) {
    for (final builder in embedBuilders) {
      if (builder.key == embeddable.type) {
        final text = builder.toPlainText(embedNode);
        // Enforce non-empty — fall back to replacement character.
        return text.isEmpty ? Embed.kObjectReplacementCharacter : text;
      }
    }
  }

  if (unknownEmbedBuilder != null) {
    final text = unknownEmbedBuilder.toPlainText(embedNode);
    return text.isEmpty ? Embed.kObjectReplacementCharacter : text;
  }

  return Embed.kObjectReplacementCharacter;
}
