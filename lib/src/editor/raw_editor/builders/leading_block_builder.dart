import 'package:flutter/material.dart';
import '../../../document/attribute.dart';
import '../../../document/nodes/node.dart';
import '../../style_widgets/checkbox_point.dart';

typedef LeadingBlockNodeBuilder = Widget? Function(Node, LeadingConfigurations);

/// This class contains all necessary values
/// to build the leading for lists and codeblocks
///
/// If you want to customize the number point of the codeblock
/// please, take care about it, because the default
/// implementation uses the same leading of
/// ordered list to show lines with correct format
class LeadingConfigurations {
  LeadingConfigurations({
    required this.attribute,
    required this.indentLevelCounts,
    required this.count,
    required this.style,
    required this.width,
    required this.padding,
    required this.value,
    required this.onCheckboxTap,
    required this.attrs,
    this.withDot = true,
    this.index,
    this.lineSize,
    this.enabled,
    this.uiBuilder,
  });

  final Attribute attribute;
  final Map<String, Attribute> attrs;
  final bool withDot;
  final Map<int, int> indentLevelCounts;
  // if is a list that contains a number as its leading then this is non null
  final int? index;
  final int count;
  final TextStyle? style;
  final double? width;
  final double? padding;

  // these values are used if the leading is from a check list
  final QuillCheckboxBuilder? uiBuilder;
  final double? lineSize;
  final bool? enabled;
  final bool value;
  final void Function(bool) onCheckboxTap;

  String? get getIndexNumberByIndent {
    if (index == null) return null;
    var s = index.toString();
    var level = 0;
    if (!attrs.containsKey(Attribute.indent.key) && indentLevelCounts.isEmpty) {
      indentLevelCounts.clear();
      indentLevelCounts[0] = 1;
      return s;
    }
    if (attrs.containsKey(Attribute.indent.key)) {
      level = attrs[Attribute.indent.key]!.value;
    } else if (!indentLevelCounts.containsKey(0)) {
      // first level but is back from previous indent level
      // supposed to be "2."
      indentLevelCounts[0] = 1;
    }
    if (indentLevelCounts.containsKey(level + 1)) {
      // last visited level is done, going up
      indentLevelCounts.remove(level + 1);
    }
    final count = (indentLevelCounts[level] ?? 0) + 1;
    indentLevelCounts[level] = count;

    s = count.toString();
    if (level % 3 == 1) {
      // a. b. c. d. e. ...
      s = _toExcelSheetColumnTitle(count);
    } else if (level % 3 == 2) {
      // i. ii. iii. ...
      s = _intToRoman(count);
    }
    return s;
  }

  String _toExcelSheetColumnTitle(int n) {
    final result = StringBuffer();
    while (n > 0) {
      n--;
      result.write(String.fromCharCode((n % 26).floor() + 97));
      n = (n / 26).floor();
    }

    return result.toString().split('').reversed.join();
  }

  String _intToRoman(int input) {
    var num = input;

    if (num < 0) {
      return '';
    } else if (num == 0) {
      return 'nulla';
    }

    final builder = StringBuffer();
    for (var a = 0; a < _arabianRomanNumbers.length; a++) {
      final times = (num / _arabianRomanNumbers[a])
          .truncate(); // equals 1 only when arabianRomanNumbers[a] = num
      // executes n times where n is the number of times you have to add
      // the current roman number value to reach current num.
      builder.write(_romanNumbers[a] * times);
      num -= times *
          _arabianRomanNumbers[
              a]; // subtract previous roman number value from num
    }

    return builder.toString().toLowerCase();
  }
}

const _arabianRomanNumbers = <int>[
  1000,
  900,
  500,
  400,
  100,
  90,
  50,
  40,
  10,
  9,
  5,
  4,
  1
];

const _romanNumbers = <String>[
  'M',
  'CM',
  'D',
  'CD',
  'C',
  'XC',
  'L',
  'XL',
  'X',
  'IX',
  'V',
  'IV',
  'I'
];
