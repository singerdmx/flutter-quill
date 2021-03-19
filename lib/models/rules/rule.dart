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

  validateArgs(int? len, Object? data, Attribute? attribute);

  Delta? applyRule(Delta document, int index,
      {int? len, Object? data, Attribute? attribute});

  RuleType get type;
}

class Rules {
  final List<Rule> _rules;
  static final Rules _instance = Rules([
    FormatLinkAtCaretPositionRule(),
    ResolveLineFormatRule(),
    ResolveInlineFormatRule(),
    InsertEmbedsRule(),
    ForceNewlineForInsertsAroundEmbedRule(),
    AutoExitBlockRule(),
    PreserveBlockStyleOnInsertRule(),
    PreserveLineStyleOnSplitRule(),
    ResetLineFormatOnNewLineRule(),
    AutoFormatLinksRule(),
    PreserveInlineStylesRule(),
    CatchAllInsertRule(),
    EnsureEmbedLineRule(),
    PreserveLineStyleOnMergeRule(),
    CatchAllDeleteRule(),
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
          print("Rule $rule applied");
          return result..trim();
        }
      } catch (e) {
        throw e;
      }
    }
    throw ('Apply rules failed');
  }
}
