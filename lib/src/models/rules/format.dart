import 'package:meta/meta.dart' show immutable;

import '../../../quill_delta.dart';
import '../../models/documents/document.dart';
import '../documents/attribute.dart';
import 'rule.dart';

/// A heuristic rule for format (retain) operations.
@immutable
abstract class FormatRule extends Rule {
  const FormatRule();

  @override
  RuleType get type => RuleType.format;

  @override
  void validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(len != null);
    assert(data == null);
    assert(attribute != null);
  }
}

/// Produces Delta with line-level attributes applied strictly to
/// newline characters.
@immutable
class ResolveLineFormatRule extends FormatRule {
  const ResolveLineFormatRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (attribute!.scope != AttributeScope.block) {
      return null;
    }

    // Apply line styles to all newline characters within range of this
    // retain operation.
    var result = Delta()..retain(index);
    final itr = DeltaIterator(document.toDelta())..skip(index);
    Operation op;
    for (var cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      final opText = op.data is String ? op.data as String : '';
      if (!opText.contains('\n')) {
        result.retain(op.length!);
        continue;
      }

      final delta = _applyAttribute(opText, op, attribute);
      result = result.concat(delta);
    }
    // And include extra newline after retain
    while (itr.hasNext) {
      op = itr.next();
      final opText = op.data is String ? op.data as String : '';
      final lf = opText.indexOf('\n');
      if (lf < 0) {
        result.retain(op.length!);
        continue;
      }

      final delta = _applyAttribute(opText, op, attribute, firstOnly: true);
      result = result.concat(delta);
      break;
    }
    return result;
  }

  Delta _applyAttribute(String text, Operation op, Attribute attribute,
      {bool firstOnly = false}) {
    final result = Delta();
    var offset = 0;
    var lf = text.indexOf('\n');
    final removedBlocks = _getRemovedBlocks(attribute, op);
    while (lf >= 0) {
      final actualStyle = attribute.toJson()..addEntries(removedBlocks);
      result
        ..retain(lf - offset)
        ..retain(1, actualStyle);

      if (firstOnly) {
        return result;
      }

      offset = lf + 1;
      lf = text.indexOf('\n', offset);
    }
    // Retain any remaining characters in text
    result.retain(text.length - offset);
    return result;
  }

  Iterable<MapEntry<String, dynamic>> _getRemovedBlocks(
      Attribute<dynamic> attribute, Operation op) {
    // Enforce Block Format exclusivity by rule
    if (!Attribute.exclusiveBlockKeys.contains(attribute.key)) {
      return <MapEntry<String, dynamic>>[];
    }

    return op.attributes?.keys
            .where((key) =>
                Attribute.exclusiveBlockKeys.contains(key) &&
                attribute.key != key &&
                attribute.value != null)
            .map((key) => MapEntry<String, dynamic>(key, null)) ??
        [];
  }
}

/// Allows updating link format with collapsed selection.
@immutable
class FormatLinkAtCaretPositionRule extends FormatRule {
  const FormatLinkAtCaretPositionRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (attribute!.key != Attribute.link.key || len! > 0) {
      return null;
    }

    final delta = Delta();
    final itr = DeltaIterator(document.toDelta());
    final before = itr.skip(index), after = itr.next();
    int? beg = index, retain = 0;
    if (before != null && before.hasAttribute(attribute.key)) {
      beg -= before.length!;
      retain = before.length;
    }
    if (after.hasAttribute(attribute.key)) {
      if (retain != null) retain += after.length!;
    }
    if (retain == 0) {
      return null;
    }

    delta
      ..retain(beg)
      ..retain(retain!, attribute.toJson());
    return delta;
  }
}

/// Produces Delta with inline-level attributes applied to all characters
/// except newlines.
@immutable
class ResolveInlineFormatRule extends FormatRule {
  const ResolveInlineFormatRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (attribute!.scope != AttributeScope.inline) {
      return null;
    }

    final delta = Delta()..retain(index);
    final itr = DeltaIterator(document.toDelta())..skip(index);

    Operation op;
    for (var cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      final text = op.data is String ? (op.data as String?)! : '';
      var lineBreak = text.indexOf('\n');
      if (lineBreak < 0) {
        delta.retain(op.length!, attribute.toJson());
        continue;
      }
      var pos = 0;
      while (lineBreak >= 0) {
        delta
          ..retain(lineBreak - pos, attribute.toJson())
          ..retain(1);
        pos = lineBreak + 1;
        lineBreak = text.indexOf('\n', pos);
      }
      if (pos < op.length!) {
        delta.retain(op.length! - pos, attribute.toJson());
      }
    }

    return delta;
  }
}

/// Produces Delta with attributes applied to image leaf node
@immutable
class ResolveImageFormatRule extends FormatRule {
  const ResolveImageFormatRule();

  @override
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    if (attribute == null || attribute.key != Attribute.style.key) {
      return null;
    }

    assert(len == 1 && data == null);

    final delta = Delta()
      ..retain(index)
      ..retain(1, attribute.toJson());

    return delta;
  }
}
