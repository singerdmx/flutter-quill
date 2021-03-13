import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/quill_delta.dart';
import 'package:flutter_quill/models/rules/rule.dart';

abstract class FormatRule extends Rule {
  const FormatRule();

  @override
  RuleType get type => RuleType.FORMAT;

  @override
  validateArgs(int? len, Object? data, Attribute? attribute) {
    assert(len != null);
    assert(data == null);
    assert(attribute != null);
  }
}

class ResolveLineFormatRule extends FormatRule {
  const ResolveLineFormatRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.scope != AttributeScope.BLOCK) {
      return null;
    }

    Delta delta = Delta()..retain(index);
    DeltaIterator itr = DeltaIterator(document);
    itr.skip(index);
    Operation op;
    for (int cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      if (op.data is! String || !(op.data as String).contains('\n')) {
        delta.retain(op.length!);
        continue;
      }
      String text = op.data as String;
      Delta tmp = Delta();
      int offset = 0;

      for (int lineBreak = text.indexOf('\n');
          lineBreak >= 0;
          lineBreak = text.indexOf('\n', offset)) {
        tmp..retain(lineBreak - offset)..retain(1, attribute.toJson());
        offset = lineBreak + 1;
      }
      tmp.retain(text.length - offset);
      delta = delta.concat(tmp);
    }

    while (itr.hasNext) {
      op = itr.next();
      String text = op.data is String ? (op.data as String?)! : '';
      int lineBreak = text.indexOf('\n');
      if (lineBreak < 0) {
        delta..retain(op.length!);
        continue;
      }
      delta..retain(lineBreak)..retain(1, attribute.toJson());
      break;
    }
    return delta;
  }
}

class FormatLinkAtCaretPositionRule extends FormatRule {
  const FormatLinkAtCaretPositionRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.key != Attribute.link.key || len! > 0) {
      return null;
    }

    Delta delta = Delta();
    DeltaIterator itr = DeltaIterator(document);
    Operation? before = itr.skip(index), after = itr.next();
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

    delta..retain(beg)..retain(retain!, attribute.toJson());
    return delta;
  }
}

class ResolveInlineFormatRule extends FormatRule {
  const ResolveInlineFormatRule();

  @override
  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    if (attribute!.scope != AttributeScope.INLINE) {
      return null;
    }

    Delta delta = Delta()..retain(index);
    DeltaIterator itr = DeltaIterator(document);
    itr.skip(index);

    Operation op;
    for (int cur = 0; cur < len! && itr.hasNext; cur += op.length!) {
      op = itr.next(len - cur);
      String text = op.data is String ? (op.data as String?)! : '';
      int lineBreak = text.indexOf('\n');
      if (lineBreak < 0) {
        delta.retain(op.length!, attribute.toJson());
        continue;
      }
      int pos = 0;
      while (lineBreak >= 0) {
        delta..retain(lineBreak - pos, attribute.toJson())..retain(1);
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
