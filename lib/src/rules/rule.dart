import 'package:flutter/foundation.dart' show immutable;

import '../../quill_delta.dart';
import '../document/attribute.dart';
import '../document/document.dart';
import 'delete.dart';
import 'format.dart';
import 'insert.dart';

enum RuleType { insert, delete, format }

@immutable
abstract class Rule {
  const Rule();

  Delta? apply(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    validateArgs(len, data, attribute);
    return applyRule(
      document,
      index,
      len: len,
      data: data,
      attribute: attribute,
    );
  }

  void validateArgs(int? len, Object? data, Attribute? attribute);

  /// Applies heuristic rule to an operation on a [document] and returns
  /// resulting [Delta].
  Delta? applyRule(
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  });

  RuleType get type;
}

class Rules {
  Rules(this._rules);

  List<Rule> _customRules = [];

  final List<Rule> _rules;
  static final Rules _instance = Rules(const [
    FormatLinkAtCaretPositionRule(),
    ResolveLineFormatRule(),
    ResolveInlineFormatRule(),
    ResolveImageFormatRule(),
    InsertEmbedsRule(),
    AutoExitBlockRule(),
    PreserveBlockStyleOnInsertRule(),
    PreserveLineStyleOnSplitRule(),
    ResetLineFormatOnNewLineRule(),
    AutoFormatLinksRule(),
    AutoFormatMultipleLinksRule(),
    PreserveInlineStylesRule(),
    CatchAllInsertRule(),
    EnsureEmbedLineRule(),
    PreserveLineStyleOnMergeRule(),
    CatchAllDeleteRule(),
    EnsureLastLineBreakDeleteRule()
  ]);

  static Rules getInstance() => _instance;

  void setCustomRules(List<Rule> customRules) {
    _customRules = customRules;
  }

  Delta apply(
    RuleType ruleType,
    Document document,
    int index, {
    int? len,
    Object? data,
    Attribute? attribute,
  }) {
    for (final rule in _customRules + _rules) {
      if (rule.type != ruleType) {
        continue;
      }
      try {
        final result = rule.apply(document, index,
            len: len, data: data, attribute: attribute);
        if (result != null) {
          return result..trim();
        }
      } catch (e) {
        rethrow;
      }
    }
    throw FormatException(
      'Apply delta rules failed. No matching rule found for type: $ruleType',
    );
  }
}
