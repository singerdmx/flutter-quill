import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget_tester_extension.dart';

extension QuillWidgetTesterNodesSelectionExtension on WidgetTester {
  /// Return all the nodes that are being selected
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  Future<Iterable<Node>> getNodesInSelection(Finder editorFinder) async {
    final hasFocus = await quillHasFocusEditor(editorFinder);
    expect(hasFocus, isTrue, reason: 'The editor must already have focus');
    final editor = findRawEditor(editorFinder);
    final selection = editor.textEditingValue.selection;
    if (!selection.isValid || selection.isCollapsed) return [];
    final start =
        editor.controller.document.queryChild(selection.baseOffset).node;
    final end =
        editor.controller.document.queryChild(selection.extentOffset).node;
    expect(start, isNotNull,
        reason: 'The node at offset: ${selection.start} was not founded');
    expect(end, isNotNull,
        reason: 'The node at offset: ${selection.end} was not founded');
    if (start == end) {
      return [start!];
    }
    var nextChild = start?.next;
    expect(nextChild, isNotNull);

    final nodesInSelection = <Node>[start!, nextChild!];
    while (nextChild != end) {
      nextChild = nextChild?.next;
      nodesInSelection.add(nextChild!);
    }
    return [...nodesInSelection];
  }

  /// Return the node in selection
  ///
  /// The widget specified by [finder] must already have focus and be a
  /// [QuillEditor] or have a [QuillEditor] descendant. For example
  /// `find.byType(QuillEditor)`.
  ///
  Future<Node?> getNodeInSelection(Finder editorFinder) async {
    final hasFocus = await quillHasFocusEditor(editorFinder);
    expect(hasFocus, isTrue, reason: 'The editor must already have focus');
    final editor = findRawEditor(editorFinder);
    final selection = editor.textEditingValue.selection;
    if (!selection.isValid) return null;
    final start =
        editor.controller.document.queryChild(selection.baseOffset).node;
    final end =
        editor.controller.document.queryChild(selection.extentOffset).node;
    expect(start, isNotNull,
        reason: 'The node at offset: ${start?.documentOffset} was not founded');
    final isSelectionIntoSameNode = start == end;
    if (isSelectionIntoSameNode) {
      return start!;
    }
    return null;
  }
}
