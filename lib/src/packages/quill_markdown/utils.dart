//ignore_for_file: cast_nullable_to_non_nullable
import '../../../flutter_quill.dart';

import '../../../quill_delta.dart';
import './embeddable_table_syntax.dart';

/// To allow embedding images/videos in horizontal mode.
const BlockEmbed horizontalRule = BlockEmbed(horizontalRuleType, 'hr');

/// Necessary for [horizontalRule] BlockEmbed.
const String horizontalRuleType = 'divider';

/// Format the passed delta to ensure that there is new line
/// after embeds
Delta transform(Delta delta) {
  final res = Delta();
  final ops = delta.toList();
  for (var i = 0; i < ops.length; i++) {
    final op = ops[i];
    res.push(op);
    autoAppendNewlineAfterEmbeddable(i, ops, op, res, [
      'hr',
      EmbeddableTable.tableType,
    ]);
  }
  return res;
}

/// Appends new line after embeds if needed
void autoAppendNewlineAfterEmbeddable(
  int i,
  List<Operation> ops,
  Operation op,
  Delta res,
  List<String> types,
) {
  final nextOpIsEmbed = i + 1 < ops.length &&
      ops[i + 1].isInsert &&
      ops[i + 1].data is Map &&
      types.any((type) => (ops[i + 1].data as Map).containsKey(type));

  if (nextOpIsEmbed &&
      op.data is String &&
      (op.data as String).isNotEmpty &&
      !(op.data as String).endsWith('\n')) {
    res.push(Operation.insert('\n'));
  }
  // embed could be image or video
  final opInsertEmbed = op.isInsert &&
      op.data is Map &&
      types.any((type) => (op.data as Map).containsKey(type));
  final nextOpIsLineBreak = i + 1 < ops.length &&
      ops[i + 1].isInsert &&
      ops[i + 1].data is String &&
      (ops[i + 1].data as String).startsWith('\n');
  if (opInsertEmbed && (i + 1 == ops.length - 1 || !nextOpIsLineBreak)) {
    // automatically append '\n' for embeddable
    res.push(Operation.insert('\n'));
  }
}
