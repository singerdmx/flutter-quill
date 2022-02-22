import 'package:flutter/widgets.dart';
import '../../models/documents/attribute.dart';
import '../../models/documents/nodes/line.dart' as line;
import '../default_styles.dart';
import '../delegate.dart';
import '../style_widgets/style_widgets.dart';

Widget? defaultLeadingBuilder(
    BuildContext context,
    line.Line line,
    int index,
    Map<int, int> indentLevelCounts,
    int count,
    CheckboxTapCallback onCheckboxTap,
    bool readOnly) {
  final defaultStyles = QuillStyles.getStyles(context, false);
  final attrs = line.style.attributes;
  if (attrs[Attribute.list.key] == Attribute.ol) {
    return QuillNumberPoint(
      index: index,
      indentLevelCounts: indentLevelCounts,
      count: count,
      style: defaultStyles!.leading!.style,
      attrs: attrs,
      width: 32,
      padding: 8,
    );
  }

  if (attrs[Attribute.list.key] == Attribute.ul) {
    return QuillBulletPoint(
      style:
          defaultStyles!.leading!.style.copyWith(fontWeight: FontWeight.bold),
      width: 32,
    );
  }

  if (attrs[Attribute.list.key] == Attribute.checked) {
    return CheckboxPoint(
      size: 14,
      value: true,
      enabled: !readOnly,
      onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
      uiBuilder: defaultStyles?.lists?.checkboxUIBuilder,
    );
  }

  if (attrs[Attribute.list.key] == Attribute.unchecked) {
    return CheckboxPoint(
      size: 14,
      value: false,
      enabled: !readOnly,
      onChanged: (checked) => onCheckboxTap(line.documentOffset, checked),
      uiBuilder: defaultStyles?.lists?.checkboxUIBuilder,
    );
  }

  if (attrs.containsKey(Attribute.codeBlock.key)) {
    return QuillNumberPoint(
      index: index,
      indentLevelCounts: indentLevelCounts,
      count: count,
      style: defaultStyles!.code!.style
          .copyWith(color: defaultStyles.code!.style.color!.withOpacity(0.4)),
      width: 32,
      attrs: attrs,
      padding: 16,
      withDot: false,
    );
  }
  return null;
}
