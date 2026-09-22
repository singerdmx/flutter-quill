@TestOn('browser')
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController.basic()
      ..document = Document.fromJson([
        {'insert': 'Splitting bills with friends\n'},
      ]);
  });

  tearDown(() => controller.dispose());

  Future<Offset> pumpEditor(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(autoFocus: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tester.getTopLeft(find.byType(QuillEditor));
  }

  Future<void> rightClick(WidgetTester tester, Offset position) async {
    final gesture = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.down(position);
    await tester.pump();
  }

  // What the browser reports when it moves the DOM selection of the hidden
  // textarea while opening its context menu.
  void browserMovesSelection(WidgetTester tester, TextSelection selection) {
    final state = tester.state<QuillRawEditorState>(
      find.byType(QuillRawEditor),
    );
    state.updateEditingValue(
      state.currentTextEditingValue!.copyWith(selection: selection),
    );
  }

  testWidgets('right click keeps a non-collapsed selection', (tester) async {
    final topLeft = await pumpEditor(tester);
    const selection = TextSelection(baseOffset: 0, extentOffset: 9);
    controller.updateSelection(selection, ChangeSource.local);
    await tester.pump();

    await rightClick(tester, topLeft + const Offset(150, 10));
    browserMovesSelection(tester, const TextSelection.collapsed(offset: 29));
    await tester.pump();

    expect(controller.selection, selection);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('right click places the caret at the click position', (
    tester,
  ) async {
    final topLeft = await pumpEditor(tester);
    controller.updateSelection(
      const TextSelection.collapsed(offset: 0),
      ChangeSource.local,
    );
    await tester.pump();

    await rightClick(tester, topLeft + const Offset(150, 10));
    final caret = controller.selection;
    expect(caret.isCollapsed, isTrue);
    expect(caret.baseOffset, greaterThan(0));

    browserMovesSelection(tester, const TextSelection.collapsed(offset: 29));
    await tester.pump();

    expect(controller.selection, caret);
    await tester.pump(const Duration(seconds: 1));
  });
}
