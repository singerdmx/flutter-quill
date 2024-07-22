import 'package:flutter/widgets.dart' show immutable;

import '../../quill_delta.dart';
import '../common/extensions/uri_ext.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import '../document/nodes/embeddable.dart';
import '../document/style.dart';
import 'rule.dart';

/// A heuristic rule for insert operations.
@immutable
abstract class InsertRule extends Rule {
  const InsertRule();

  @override
  RuleType get type => RuleType.insert;

  @override
  void validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(data != null);
    assert(attribute == null);
  }
}

/// Preserves line format when user splits the line into two.
///
/// This rule ignores scenarios when the line is split on its edge, meaning
/// a newline is inserted at the beginning or the end of a line.
@immutable
class PreserveLineStyleOnSplitRule extends InsertRule {
  const PreserveLineStyleOnSplitRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || data != '\n') {
      return null;
    }
    final itr = DeltaIterator(document.toDelta());
    final before = itr.skip(index);
    if (before == null) {
      return null;
    }
    if (before.data is String && (before.data as String).endsWith('\n')) {
      return null;
    }

    final after = itr.next();
    if (after.data is String && (after.data as String).startsWith('\n')) {
      return null;
    }

    final delta = Delta()..retain(index + (len ?? 0));
    if (after.data is String && (after.data as String).contains('\n')) {
      assert(after.isPlain);
      delta.insert('\n');
      return delta;
    }
    final nextNewLine = _getNextNewLine(itr);
    final attributes = nextNewLine.operation?.attributes;

    return delta..insert('\n', attributes);
  }
}

/// Preserves block style when user inserts text containing newlines.
///
/// This rule handles:
///
///   * inserting a new line in a block
///   * pasting text containing multiple lines of text in a block
///
/// This rule may also be activated for changes triggered by auto-correct.
@immutable
class PreserveBlockStyleOnInsertRule extends InsertRule {
  const PreserveBlockStyleOnInsertRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || !data.contains('\n')) {
      // Only interested in text containing at least one newline character.
      return null;
    }
    final itr = DeltaIterator(document.toDelta())..skip(index);

    // Look for the next newline.
    final nextNewLine = _getNextNewLine(itr);
    final lineStyle = Style.fromJson(
        nextNewLine.operation?.attributes ?? <String, dynamic>{});

    final blockStyle = lineStyle.getBlocksExceptHeader();
    // Are we currently in a block? If not then ignore.
    if (blockStyle.isEmpty) {
      return null;
    }

    final resetStyle = <String, dynamic>{};
    // If current line had heading style applied to it we'll need to move this
    // style to the newly inserted line before it and reset style of the
    // original line.
    if (lineStyle.containsKey(Attribute.header.key)) {
      resetStyle.addAll(Attribute.header.toJson());
    }

    // Go over each inserted line and ensure block style is applied.
    final lines = data.split('\n');
    final delta = Delta()..retain(index + (len ?? 0));
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isNotEmpty) {
        delta.insert(line);
      }
      if (i == 0) {
        // The first line should inherit the lineStyle entirely.
        delta.insert('\n', lineStyle.toJson());
      } else if (i < lines.length - 1) {
        // we don't want to insert a newline after the last chunk of text, so -1
        final blockAttributes = blockStyle.isEmpty
            ? null
            : blockStyle.map<String, dynamic>((_, attribute) =>
                MapEntry<String, dynamic>(attribute.key, attribute.value));
        delta.insert('\n', blockAttributes);
      }
    }

    // Reset style of the original newline character if needed.
    if (resetStyle.isNotEmpty) {
      delta
        ..retain(nextNewLine.skipped!)
        ..retain((nextNewLine.operation!.data as String).indexOf('\n'))
        ..retain(1, resetStyle);
    }

    return delta;
  }
}

/// Heuristic rule to exit current block when user inserts two consecutive
/// newlines.
///
/// This rule is only applied when the cursor is on the last line of a block.
/// When the cursor is in the middle of a block we allow adding empty lines
/// and preserving the block's style.
@immutable
class AutoExitBlockRule extends InsertRule {
  const AutoExitBlockRule();

  bool _isEmptyLine(Operation? before, Operation? after) {
    if (before == null) {
      return true;
    }
    return before.data is String &&
        (before.data as String).endsWith('\n') &&
        after!.data is String &&
        (after.data as String).startsWith('\n');
  }

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || data != '\n') {
      return null;
    }

    final itr = DeltaIterator(document.toDelta());
    final prev = itr.skip(index), cur = itr.next();
    final blockStyle = Style.fromJson(cur.attributes).getBlockExceptHeader();
    // We are not in a block, ignore.
    if (cur.isPlain || blockStyle == null) {
      return null;
    }
    // We are not on an empty line, ignore.
    if (!_isEmptyLine(prev, cur)) {
      return null;
    }

    // We are on an empty line. Now we need to determine if we are on the
    // last line of a block.
    // First check if `cur` length is greater than 1, this would indicate
    // that it contains multiple newline characters which share the same style.
    // This would mean we are not on the last line yet.
    // `cur.value as String` is safe since we already called isEmptyLine and
    // know it contains a newline
    if ((cur.value as String).length > 1) {
      // We are not on the last line of this block, ignore.
      return null;
    }

    // Keep looking for the next newline character to see if it shares the same
    // block style as `cur`.
    final nextNewLine = _getNextNewLine(itr);
    if (nextNewLine.operation != null &&
        nextNewLine.operation!.attributes != null &&
        Style.fromJson(nextNewLine.operation!.attributes)
                .getBlockExceptHeader() ==
            blockStyle) {
      // We are not at the end of this block, ignore.
      return null;
    }

    // Here we now know that the line after `cur` is not in the same block
    // therefore we can exit this block.
    final attributes = cur.attributes ?? <String, dynamic>{};
    final k =
        attributes.keys.firstWhere(Attribute.blockKeysExceptHeader.contains);
    attributes[k] = null;
    // retain(1) should be '\n', set it with no attribute
    return Delta()
      ..retain(index + (len ?? 0))
      ..retain(1, attributes);
  }
}

/// Resets format for a newly inserted line when insert occurred at the end
/// of a line (right before a newline).
///
/// This handles scenarios when a new line is added when at the end of a
/// heading line. The newly added line should be a regular paragraph.
@immutable
class ResetLineFormatOnNewLineRule extends InsertRule {
  const ResetLineFormatOnNewLineRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || data != '\n') {
      return null;
    }

    final itr = DeltaIterator(document.toDelta())..skip(index);
    final cur = itr.next();
    if (cur.data is! String || !(cur.data as String).startsWith('\n')) {
      return null;
    }

    Map<String, dynamic>? resetStyle;
    if (cur.attributes != null &&
        cur.attributes!.containsKey(Attribute.header.key)) {
      resetStyle = Attribute.header.toJson();
    }
    return Delta()
      ..retain(index + (len ?? 0))
      ..insert('\n', cur.attributes)
      ..retain(1, resetStyle)
      ..trim();
  }
}

/// Handles all format operations which manipulate embeds.
/// This rule wraps line breaks around video, not image.
@immutable
class InsertEmbedsRule extends InsertRule {
  const InsertEmbedsRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is String) {
      return null;
    }

    assert(data is Map);

    if (!(data as Map).containsKey(BlockEmbed.videoType)) {
      return null;
    }

    final delta = Delta()..retain(index + (len ?? 0));
    final itr = DeltaIterator(document.toDelta());
    final prev = itr.skip(index), cur = itr.next();

    final textBefore = prev?.data is String ? prev!.data as String? : '';
    final textAfter = cur.data is String ? (cur.data as String?)! : '';

    final isNewlineBefore = prev == null || textBefore!.endsWith('\n');
    final isNewlineAfter = textAfter.startsWith('\n');

    if (isNewlineBefore && isNewlineAfter) {
      return delta..insert(data);
    }

    Map<String, dynamic>? lineStyle;
    if (textAfter.contains('\n')) {
      lineStyle = cur.attributes;
    } else {
      while (itr.hasNext) {
        final op = itr.next();
        if ((op.data is String ? op.data as String? : '')!.contains('\n')) {
          lineStyle = op.attributes;
          break;
        }
      }
    }

    if (!isNewlineBefore) {
      delta.insert('\n', lineStyle);
    }
    delta.insert(data);
    if (!isNewlineAfter) {
      delta.insert('\n');
    }
    return delta;
  }
}

/// Applies link format to text segments within the inserted text that matches
/// the URL pattern.
///
/// The link attribute is applied as the user types.
@immutable
class AutoFormatMultipleLinksRule extends InsertRule {
  const AutoFormatMultipleLinksRule();

  /// Link pattern.
  ///
  /// This pattern is used to match a links within a text segment.
  ///
  /// It works for the following testing URLs:
  // www.google.com
  // http://google.com
  // https://www.google.com
  // http://beginner.example.edu/#act
  // https://birth.example.net/beds/ants.php#bait
  // http://example.com/babies
  // https://www.example.com/
  // https://attack.example.edu/?acoustics=blade&bed=bed
  // http://basketball.example.com/
  // https://birthday.example.com/birthday
  // http://www.example.com/
  // https://example.com/addition/action
  // http://example.com/
  // https://bite.example.net/#adjustment
  // http://www.example.net/badge.php?bedroom=anger
  // https://brass.example.com/?anger=branch&actor=amusement#adjustment
  // http://www.example.com/?action=birds&brass=apparatus
  // https://example.net/
  // URL generator tool (https://www.randomlists.com/urls) is used.

  static const _oneLineLinkPattern =
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)*(:\d+)?(\/.*)?$';
  static const _detectLinkPattern =
      r'https?:\/\/[\w\-]+(\.[\w\-]+)*(:\d+)?(\/[^\s]*)?';

  /// It requires a valid link in one link
  RegExp get oneLineLinkRegExp => RegExp(
        _oneLineLinkPattern,
        caseSensitive: false,
      );

  /// It detect if there is a link in the text whatever if it in the middle etc
  // Used to solve bug https://github.com/singerdmx/flutter-quill/issues/1432
  RegExp get detectLinkRegExp => RegExp(
        _detectLinkPattern,
        caseSensitive: false,
      );
  RegExp get linkRegExp => oneLineLinkRegExp;

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
    Object? extraData,
  }) {
    // Only format when inserting text.
    if (data is! String) return null;

    // Get current text.
    final entireText = document.toPlainText();

    // Get word before insertion.
    final leftWordPart = entireText
        // Keep all text before insertion.
        .substring(0, index)
        // Keep last paragraph.
        .split('\n')
        .last
        // Keep last word.
        .split(' ')
        .last
        .trimLeft();

    // Get word after insertion.
    final rightWordPart = entireText
        // Keep all text after insertion.
        .substring(index)
        // Keep first paragraph.
        .split('\n')
        .first
        // Keep first word.
        .split(' ')
        .first
        .trimRight();

    // Build the segment of affected words.
    final affectedWords = '$leftWordPart$data$rightWordPart';

    var usedRegExp = detectLinkRegExp;
    final alternativeLinkRegExp = extraData;
    if (alternativeLinkRegExp != null) {
      try {
        if (alternativeLinkRegExp is! String) {
          throw ArgumentError.value(
            alternativeLinkRegExp,
            'alternativeLinkRegExp',
            '`alternativeLinkRegExp` should be of type String',
          );
        }
        final regPattern = alternativeLinkRegExp;
        usedRegExp = RegExp(
          regPattern,
          caseSensitive: false,
        );
      } catch (_) {}
    }

    // Check for URL pattern.
    final matches = usedRegExp.allMatches(affectedWords);

    // If there are no matches, do not apply any format.
    if (matches.isEmpty) return null;

    // Build base delta.
    // The base delta is a simple insertion delta.
    final baseDelta = Delta()
      ..retain(index)
      ..insert(data);

    // Get unchanged text length.
    final unmodifiedLength = index - leftWordPart.length;

    // Create formatter delta.
    // The formatter delta will only include links formatting when needed.
    final formatterDelta = Delta()..retain(unmodifiedLength);

    var previousLinkEndRelativeIndex = 0;
    for (final match in matches) {
      // Get the size of the leading segment of text that is not part of the
      // link.
      final separationLength = match.start - previousLinkEndRelativeIndex;

      // Get the identified link.
      final link = affectedWords.substring(match.start, match.end);

      // Keep the leading segment of text and add link with its proper
      // attribute.
      formatterDelta
        ..retain(separationLength, Attribute.link.toJson())
        ..retain(link.length, LinkAttribute(link).toJson());

      // Update reference index.
      previousLinkEndRelativeIndex = match.end;
    }

    // Get remaining text length.
    final remainingLength = affectedWords.length - previousLinkEndRelativeIndex;

    // Remove links from remaining non-link text.
    formatterDelta.retain(remainingLength, Attribute.link.toJson());

    // Build and return resulting change delta.
    return baseDelta.compose(formatterDelta);
  }
}

/// Applies link format to text segment (which looks like a link) when user
/// inserts space character after it.
@immutable
class AutoFormatLinksRule extends InsertRule {
  const AutoFormatLinksRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || data != ' ') {
      return null;
    }

    final itr = DeltaIterator(document.toDelta());
    final prev = itr.skip(index);
    if (prev == null || prev.data is! String) {
      return null;
    }

    try {
      final cand = (prev.data as String).split('\n').last.split(' ').last;
      final link = Uri.parse(cand);
      if (!link.isHttpBasedUrl()) {
        return null;
      }
      final attributes = prev.attributes ?? <String, dynamic>{};

      if (attributes.containsKey(Attribute.link.key)) {
        return null;
      }

      attributes.addAll(LinkAttribute(link.toString()).toJson());
      return Delta()
        ..retain(index + (len ?? 0) - cand.length)
        ..retain(cand.length, attributes)
        ..insert(data, prev.attributes);
    } on FormatException {
      return null;
    }
  }
}

/// Preserves inline styles when user inserts text inside formatted segment.
@immutable
class PreserveInlineStylesRule extends InsertRule {
  const PreserveInlineStylesRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (data is! String || data.contains('\n')) {
      return null;
    }

    final documentDelta = document.toDelta();
    final itr = DeltaIterator(documentDelta);
    len ??= 0;
    var prev = itr.skip(len == 0 ? index : index + 1);
    var excludeLinkAtLineStart = false;

    /// Process simple insertions at start of line
    if (len == 0) {
      final currLine = itr.next();

      /// Trap for previous is not text with attributes
      if (prev?.data is! String) {
        prev = currLine;
        excludeLinkAtLineStart = true;
      } else {
        final prevData = prev!.data as String;
        if (prevData.endsWith('\n')) {
          /// If current line is empty get attributes from a prior line
          final currData =
              currLine.data is String ? currLine.data as String : null;
          if (currData?.startsWith('\n') == true) {
            if (prevData.trimRight().isEmpty) {
              final back =
                  DeltaIterator(documentDelta).skip(index - prevData.length);
              if (back != null && back.data is String) {
                prev = back;
              }
            }
          } else {
            prev = currLine;
            excludeLinkAtLineStart = true;
          }
        }
      }
    }

    final attributes = <String, dynamic>{};
    if (prev?.attributes != null) {
      for (final entry in prev!.attributes!.entries) {
        if (Attribute.inlineKeys.contains(entry.key)) {
          attributes[entry.key] = entry.value;
        }
      }
    }
    if (attributes.isEmpty) {
      return null;
    }

    if (excludeLinkAtLineStart) {
      attributes.remove(Attribute.link.key);
    }
    return Delta()
      ..retain(index + len)
      ..insert(data, attributes.isEmpty ? null : attributes);
  }
}

/// Fallback rule which simply inserts text as-is without any special handling.
@immutable
class CatchAllInsertRule extends InsertRule {
  const CatchAllInsertRule();

  @override
  Delta applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    return Delta()
      ..retain(index + (len ?? 0))
      ..insert(data);
  }
}

_NextNewLine _getNextNewLine(DeltaIterator iterator) {
  Operation op;
  for (var skipped = 0; iterator.hasNext; skipped += op.length!) {
    op = iterator.next();
    final lineBreak =
        (op.data is String ? op.data as String? : '')!.indexOf('\n');
    if (lineBreak >= 0) {
      return _NextNewLine(op, skipped);
    }
  }
  return const _NextNewLine(null, null);
}

@immutable
class _NextNewLine {
  const _NextNewLine(this.operation, this.skipped);

  final Operation? operation;
  final int? skipped;
}
