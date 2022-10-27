import 'package:flutter/material.dart';

import '../../models/documents/attribute.dart';
import '../text_block.dart';

class QuillNumberPoint extends StatelessWidget {
  const QuillNumberPoint({
    required this.index,
    required this.indentLevelCounts,
    required this.count,
    required this.style,
    required this.width,
    required this.attrs,
    this.withDot = true,
    this.padding = 0.0,
    Key? key,
  }) : super(key: key);

  final int index;
  final Map<int?, int> indentLevelCounts;
  final int count;
  final TextStyle style;
  final double width;
  final Map<String, Attribute> attrs;
  final bool withDot;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final olString = _getOlString();

    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: EdgeInsetsDirectional.only(end: padding),
      child: Text('$olString${withDot ? '.' : ''}', style: style),
    );
  }

  String _getOlString() {
    final int indentLevel = attrs[Attribute.indent.key]?.value ?? 0;

    if (indentLevelCounts.containsKey(indentLevel + 1)) {
      // last visited level is done, going up
      indentLevelCounts.remove(indentLevel + 1);
    }

    final count = (indentLevelCounts[indentLevel] ?? 0) + 1;
    indentLevelCounts[indentLevel] = count;

    final numberingMode = indentLevel % 3;
    if (numberingMode == 1) {
      // a. b. c.
      return _intToAlpha(count);
    } else if (numberingMode == 2) {
      // i. ii. iii.
      return _intToRoman(count);
    }

    return count.toString();
  }

  String _intToAlpha(int n) {
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
    for (var a = 0; a < arabianRomanNumbers.length; a++) {
      final times = (num / arabianRomanNumbers[a])
          .truncate(); // equals 1 only when arabianRomanNumbers[a] = num
      // executes n times where n is the number of times you have to add
      // the current roman number value to reach current num.
      builder.write(romanNumbers[a] * times);
      num -= times *
          arabianRomanNumbers[
              a]; // subtract previous roman number value from num
    }

    return builder.toString().toLowerCase();
  }
}
