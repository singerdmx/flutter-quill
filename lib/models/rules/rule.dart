import 'package:flutter_quill/models/documents/attribute.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/models/quill_delta.dart';

import 'delete.dart';
import 'format.dart';
import 'insert.dart';

enum RuleType { INSERT, DELETE, FORMAT }

abstract class Rule {
  const Rule();

  Delta? apply(Delta document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    validateArgs(len, data, attribute);
    return applyRule(document, index,
        len: len, data: data, attribute: attribute);
  }

  void validateArgs(int? len, Object? data, Attribute? attribute);

  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute});

  RuleType get type;
}

class Rules {
  final List<Rule> _rules;
  static final Rules _instance = Rules([
    const FormatLinkAtCaretPositionRule(),
    const ResolveLineFormatRule(),
    const ResolveInlineFormatRule(),
    const InsertEmbedsRule(),
    const ForceNewlineForInsertsAroundEmbedRule(),
    const AutoExitBlockRule(),
    const PreserveBlockStyleOnInsertRule(),
    const PreserveLineStyleOnSplitRule(),
    const ResetLineFormatOnNewLineRule(),
    const AutoFormatLinksRule(),
    const PreserveInlineStylesRule(),
    const CatchAllInsertRule(),
    const EnsureEmbedLineRule(),
    const PreserveLineStyleOnMergeRule(),
    const CatchAllDeleteRule(),
  ]);

  Rules(this._rules);

  static Rules getInstance() => _instance;

  Delta apply(RuleType ruleType, Document document, int index,
      {int? len, Object? data, Attribute? attribute}) {
    final delta = document.toDelta();
    for (var rule in _rules) {
      if (rule.type != ruleType) {
        continue;
      }
      try {
        final result = rule.apply(delta, index,
            len: len, data: data, attribute: attribute);
        if (result != null) {
          return result..trim();
        }
      } catch (e) {
        rethrow;
      }
    }
    throw 'Apply rules failed';
  }
}
