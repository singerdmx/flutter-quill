import 'package:flutter/foundation.dart' show immutable;

import '../../quill_delta.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import '../document/nodes/embeddable.dart';
import 'rule.dart';

/// A heuristic rule for delete operations.
@immutable
abstract class DeleteRule extends Rule {
  const DeleteRule();

  @override
  RuleType get type => RuleType.delete;

  @override
  void validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(len != null);
    assert(data == null);
    assert(attribute == null);
  }
}

@immutable
class EnsureLastLineBreakDeleteRule extends DeleteRule {
  const EnsureLastLineBreakDeleteRule();

  @override
  Delta? applyRule(Document document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    final itr = DeltaIterator(document.toDelta())..skip(index + len!);

    return Delta()
      ..retain(index)
      ..delete(itr.hasNext ? len : len - 1);
  }
}

/// Fallback rule for delete operations which simply deletes specified text
/// range without any special handling.
@immutable
class CatchAllDeleteRule extends DeleteRule {
  const CatchAllDeleteRule();

  @override
  Delta applyRule(Document document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    final itr = DeltaIterator(document.toDelta())..skip(index + len!);

    return Delta()
      ..retain(index)
      ..delete(itr.hasNext ? len : len - 1);
  }
}

/// Preserves line format when user deletes the line's newline character
/// effectively merging it with the next line.
///
/// This rule makes sure to apply all style attributes of deleted newline
/// to the next available newline, which may reset any style attributes
/// already present there.
@immutable
class PreserveLineStyleOnMergeRule extends DeleteRule {
  const PreserveLineStyleOnMergeRule();

  @override
  Delta? applyRule(Document document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    final itr = DeltaIterator(document.toDelta())..skip(index);
    var op = itr.next(1);
    if (op.data != '\n') {
      return null;
    }

    final isNotPlain = op.isNotPlain;
    final attrs = op.attributes;

    itr.skip(len! - 1);

    if (!itr.hasNext) {
      // User attempts to delete the last newline character, prevent it.
      return Delta()
        ..retain(index)
        ..delete(len - 1);
    }

    final delta = Delta()
      ..retain(index)
      ..delete(len);

    // Check if the previous line is empty
    final prevItr = DeltaIterator(document.toDelta())..skip(index - 1);
    final prevOp = prevItr.next(1);
    if (prevOp.data == '\n') {
      // Check if the current block is at the start and not empty
      final currentBlockItr = DeltaIterator(document.toDelta())..skip(index);
      var currentBlockOp = currentBlockItr.next(1);
      final isBlockStart = currentBlockOp.data == '\n';
      var isBlockNotEmpty = false;

      while (currentBlockItr.hasNext) {
        currentBlockOp = currentBlockItr.next();
        if (currentBlockOp.data is String &&
            (currentBlockOp.data as String).contains('\n')) {
          break;
        }
        if (currentBlockOp.data is String &&
            (currentBlockOp.data as String).trim().isNotEmpty) {
          isBlockNotEmpty = true;
        }
      }

      if (isBlockStart && isBlockNotEmpty) {
        // Previous line is empty, skip the merge
        return delta;
      }
    }

    while (itr.hasNext) {
      op = itr.next();
      final text = op.data is String ? (op.data as String?)! : '';
      final lineBreak = text.indexOf('\n');
      if (lineBreak == -1) {
        delta.retain(op.length!);
        continue;
      }

      var attributes = op.attributes?.map<String, dynamic>(
          (key, dynamic value) => MapEntry<String, dynamic>(key, null));

      if (isNotPlain) {
        attributes ??= <String, dynamic>{};
        attributes.addAll(attrs!);
      }
      delta
        ..retain(lineBreak)
        ..retain(1, attributes);
      break;
    }
    return delta;
  }
}

/// Prevents user from merging a line containing an embed with other lines.
/// This rule applies to video, not image.
/// The rule relates to [InsertEmbedsRule].
@immutable
class EnsureEmbedLineRule extends DeleteRule {
  const EnsureEmbedLineRule();

  @override
  Delta? applyRule(Document document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    final itr = DeltaIterator(document.toDelta());

    var op = itr.skip(index);
    final opAfter = itr.skip(index + 1);

    // Only video embed occupies a whole line.
    if (!_isVideo(op) || !_isVideo(opAfter)) {
      return null;
    }

    int? indexDelta = 0, lengthDelta = 0, remain = len;
    var embedFound = op != null && op.data is! String;
    final hasLineBreakBefore =
        !embedFound && (op == null || (op.data as String).endsWith('\n'));
    if (embedFound) {
      var candidate = itr.next(1);
      if (remain != null) {
        remain--;
        if (candidate.data == '\n') {
          indexDelta++;
          lengthDelta--;

          candidate = itr.next(1);
          remain--;
          if (candidate.data == '\n') {
            lengthDelta++;
          }
        }
      }
    }

    op = itr.skip(remain!);
    if (op != null &&
        (op.data is String ? op.data as String? : '')!.endsWith('\n')) {
      final candidate = itr.next(1);
      if (candidate.data is! String && !hasLineBreakBefore) {
        embedFound = true;
        lengthDelta--;
      }
    }

    if (!embedFound) {
      return null;
    }

    return Delta()
      ..retain(index + indexDelta)
      ..delete(len! + lengthDelta);
  }

  bool _isVideo(op) {
    return op != null &&
        op.data is! String &&
        !(op.data as Map).containsKey(BlockEmbed.videoType);
  }
}
