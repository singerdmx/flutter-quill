import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget_tester_extension.dart';

extension QuillWidgetTesterNodesSelectionExtension on WidgetTester {
  Future<Iterable<Node>> getNodesInSelection(Finder editorFinder) async {
    final hasFocus = await quillHasFocusEditor(editorFinder);
    expect(hasFocus, isTrue,
        reason: 'Cannot be getted any Node because the editor is not focused');
    final editor = findRawEditor(editorFinder);
    final selection = editor.textEditingValue.selection;
    expect(selection.isValid, isTrue);
    final start =
        editor.controller.document.queryChild(selection.baseOffset).node;
    final end =
        editor.controller.document.queryChild(selection.extentOffset).node;
    expect(start, isNotNull);
    expect(end, isNotNull);
    if (start == end) {
      return [start!];
    }
    var nextChild = start?.next;
    expect(nextChild, isNotNull);
    final nodesInSelection = <Node>[nextChild!];
    while (nextChild != end) {
      nextChild = nextChild?.next;
      nodesInSelection.add(nextChild!);
    }
    return [...nodesInSelection];
  }
}
