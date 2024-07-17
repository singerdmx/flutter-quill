import 'package:flutter/widgets.dart';

import '../../../flutter_quill.dart';
import '../widgets/text/text_block.dart';

class QuillEditorNumberPoint extends StatelessWidget {
  const QuillEditorNumberPoint({
    required this.index,
    required this.indentLevelCounts,
    required this.count,
    required this.style,
    required this.width,
    required this.attrs,
    this.textAlign,
    this.withDot = true,
    this.padding = 0.0,
    super.key,
    this.backgroundColor,
  });

  final int index;
  final Map<int?, int> indentLevelCounts;
  final int count;
  final TextStyle style;
  final double width;
  final Map<String, Attribute> attrs;
  final bool withDot;
  final double padding;
  final Color? backgroundColor;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    var s = index.toString();
    int? level = 0;
    if (!attrs.containsKey(Attribute.indent.key) && indentLevelCounts.isEmpty) {
      indentLevelCounts.clear();
      indentLevelCounts[0] = 1;
      return Container(
        alignment: AlignmentDirectional.topEnd,
        width: width,
        padding: EdgeInsetsDirectional.only(end: padding),
        color: backgroundColor,
        child: context.quillEditorConfigurations?.elementOptions.orderedList
                .customWidget ??
            Text(
              withDot ? '$s.' : s,
              style: style,
              textAlign: textAlign,
            ),
      );
    }
    if (attrs.containsKey(Attribute.indent.key)) {
      level = attrs[Attribute.indent.key]!.value;
    } else if (!indentLevelCounts.containsKey(0)) {
      // first level but is back from previous indent level
      // supposed to be "2."
      indentLevelCounts[0] = 1;
    }
    if (indentLevelCounts.containsKey(level! + 1)) {
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
    // level % 3 == 0 goes back to 1. 2. 3.

    return Container(
      alignment: AlignmentDirectional.topEnd,
      width: width,
      padding: EdgeInsetsDirectional.only(end: padding),
      color: backgroundColor,
      child: context.quillEditorConfigurations?.elementOptions.orderedList
              .customWidget ??
          Text(
            withDot ? '$s.' : s,
            style: style,
            textAlign: textAlign,
          ),
    );
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
