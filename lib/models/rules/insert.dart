import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:flutter_quill/models/quill_delta.dart';
import 'package:flutter_quill/models/rules/rule.dart';
import 'package:tuple/tuple.dart';

abstract class InsertRule extends Rule {
  const InsertRule();

  @override
  RuleType get type => RuleType.INSERT;

  @override
  validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(len == null);
    assert(data != null);
    assert(attribute == null);
  }
}

class PreserveLineStyleOnSplitRule extends InsertRule {
  const PreserveLineStyleOnSplitRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || data != '\n') {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    Operation? before = itr.skip(index);
    if (before == null ||
        before.data is! String ||
        (before.data as String).endsWith('\n')) {
      return null;
    }
    Operation after = itr.next();
    if (after.data is! String || (after.data as String).startsWith('\n')) {
      return null;
    }

    final text = after.data as String;

    Delta delta = Delta()..retain(index);
    if (text.contains('\n')) {
      assert(after.isPlain);
      delta..insert('\n');
      return delta;
    }
    Tuple2<Operation?, int?> nextNewLine = _getNextNewLine(itr);
    Map<String, dynamic>? attributes = nextNewLine.item1?.attributes;

    return delta..insert('\n', attributes);
  }
}

class PreserveBlockStyleOnInsertRule extends InsertRule {
  const PreserveBlockStyleOnInsertRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || !data.contains('\n')) {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    itr.skip(index);

    Tuple2<Operation?, int?> nextNewLine = _getNextNewLine(itr);
    Style lineStyle =
        Style.fromJson(nextNewLine.item1?.attributes ?? <String, dynamic>{});

    Attribute? attribute = lineStyle.getBlockExceptHeader();
    if (attribute == null) {
      return null;
    }

    var blockStyle = <String, dynamic>{attribute.key: attribute.value};

    Map<String, dynamic>? resetStyle;

    if (lineStyle.containsKey(Attribute.header.key)) {
      resetStyle = Attribute.header.toJson();
    }

    List<String> lines = data.split('\n');
    Delta delta = Delta()..retain(index);
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.isNotEmpty) {
        delta.insert(line);
      }
      if (i == 0) {
        delta.insert('\n', lineStyle.toJson());
      } else if (i < lines.length - 1) {
        delta.insert('\n', blockStyle);
      }
    }

    if (resetStyle != null) {
      delta.retain(nextNewLine.item2!);
      delta
        ..retain((nextNewLine.item1!.data as String).indexOf('\n'))
        ..retain(1, resetStyle);
    }

    return delta;
  }
}

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
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || data != '\n') {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    Operation? prev = itr.skip(index), cur = itr.next();
    Attribute? blockStyle =
        Style.fromJson(cur.attributes).getBlockExceptHeader();
    if (cur.isPlain || blockStyle == null) {
      return null;
    }
    if (!_isEmptyLine(prev, cur)) {
      return null;
    }

    if ((cur.value as String).length > 1) {
      return null;
    }

    Tuple2<Operation?, int?> nextNewLine = _getNextNewLine(itr);
    if (nextNewLine.item1 != null &&
        nextNewLine.item1!.attributes != null &&
        Style.fromJson(nextNewLine.item1!.attributes).getBlockExceptHeader() ==
            blockStyle) {
      return null;
    }

    final attributes = cur.attributes ?? <String, dynamic>{};
    String k = attributes.keys
        .firstWhere((k) => Attribute.blockKeysExceptHeader.contains(k));
    attributes[k] = null;
    // retain(1) should be '\n', set it with no attribute
    return Delta()..retain(index)..retain(1, attributes);
  }
}

class ResetLineFormatOnNewLineRule extends InsertRule {
  const ResetLineFormatOnNewLineRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || data != '\n') {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    itr.skip(index);
    Operation cur = itr.next();
    if (cur.data is! String || !(cur.data as String).startsWith('\n')) {
      return null;
    }

    Map<String, dynamic>? resetStyle;
    if (cur.attributes != null &&
        cur.attributes!.containsKey(Attribute.header.key)) {
      resetStyle = Attribute.header.toJson();
    }
    return Delta()
      ..retain(index)
      ..insert('\n', cur.attributes)
      ..retain(1, resetStyle)
      ..trim();
  }
}

class InsertEmbedsRule extends InsertRule {
  const InsertEmbedsRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is String) {
      return null;
    }

    Delta delta = Delta()..retain(index);
    DeltaIterator itr = DeltaIterator(document);
    Operation? prev = itr.skip(index), cur = itr.next();

    String? textBefore = prev?.data is String ? prev!.data as String? : '';
    String textAfter = cur.data is String ? (cur.data as String?)! : '';

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
        Operation op = itr.next();
        if ((op.data is String ? op.data as String? : '')!.indexOf('\n') >= 0) {
          lineStyle = op.attributes;
          break;
        }
      }
    }

    if (!isNewlineBefore) {
      delta..insert('\n', lineStyle);
    }
    delta..insert(data);
    if (!isNewlineAfter) {
      delta..insert('\n');
    }
    return delta;
  }
}

class ForceNewlineForInsertsAroundEmbedRule extends InsertRule {
  const ForceNewlineForInsertsAroundEmbedRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String) {
      return null;
    }

    String text = data;
    DeltaIterator itr = DeltaIterator(document);
    final prev = itr.skip(index);
    final cur = itr.next();
    bool cursorBeforeEmbed = cur.data is! String;
    bool cursorAfterEmbed = prev != null && prev.data is! String;

    if (!cursorBeforeEmbed && !cursorAfterEmbed) {
      return null;
    }
    Delta delta = Delta()..retain(index);
    if (cursorBeforeEmbed && !text.endsWith('\n')) {
      return delta..insert(text)..insert('\n');
    }
    if (cursorAfterEmbed && !text.startsWith('\n')) {
      return delta..insert('\n')..insert(text);
    }
    return delta..insert(text);
  }
}

class AutoFormatLinksRule extends InsertRule {
  const AutoFormatLinksRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || data != ' ') {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    Operation? prev = itr.skip(index);
    if (prev == null || prev.data is! String) {
      return null;
    }

    try {
      String cand = (prev.data as String).split('\n').last.split(' ').last;
      Uri link = Uri.parse(cand);
      if (!['https', 'http'].contains(link.scheme)) {
        return null;
      }
      Map<String, dynamic> attributes = prev.attributes ?? <String, dynamic>{};

      if (attributes.containsKey(Attribute.link.key)) {
        return null;
      }

      attributes.addAll(LinkAttribute(link.toString()).toJson());
      return Delta()
        ..retain(index - cand.length)
        ..retain(cand.length, attributes)
        ..insert(data, prev.attributes);
    } on FormatException {
      return null;
    }
  }
}

class PreserveInlineStylesRule extends InsertRule {
  const PreserveInlineStylesRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (data is! String || data.contains('\n')) {
      return null;
    }

    DeltaIterator itr = DeltaIterator(document);
    Operation? prev = itr.skip(index);
    if (prev == null ||
        prev.data is! String ||
        (prev.data as String).contains('\n')) {
      return null;
    }

    Map<String, dynamic>? attributes = prev.attributes;
    String text = data;
    if (attributes == null || !attributes.containsKey(Attribute.link.key)) {
      return Delta()
        ..retain(index)
        ..insert(text, attributes);
    }

    attributes.remove(Attribute.link.key);
    Delta delta = Delta()
      ..retain(index)
      ..insert(text, attributes.isEmpty ? null : attributes);
    Operation next = itr.next();

    Map<String, dynamic> nextAttributes =
        next.attributes ?? const <String, dynamic>{};
    if (!nextAttributes.containsKey(Attribute.link.key)) {
      return delta;
    }
    if (attributes[Attribute.link.key] == nextAttributes[Attribute.link.key]) {
      return Delta()
        ..retain(index)
        ..insert(text, attributes);
    }
    return delta;
  }
}

class CatchAllInsertRule extends InsertRule {
  const CatchAllInsertRule();

  @override
  Delta applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    return Delta()
      ..retain(index)
      ..insert(data);
  }
}

Tuple2<Operation?, int?> _getNextNewLine(DeltaIterator iterator) {
  Operation op;
  for (int skipped = 0; iterator.hasNext; skipped += op.length!) {
    op = iterator.next();
    int lineBreak =
        (op.data is String ? op.data as String? : '')!.indexOf('\n');
    if (lineBreak >= 0) {
      return Tuple2(op, skipped);
    }
  }
  return Tuple2(null, null);
}
