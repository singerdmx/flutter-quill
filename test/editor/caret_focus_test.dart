import 'dart:ui' show ViewFocusDirection, ViewFocusEvent, ViewFocusState;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

void main() {
  final windows = TargetPlatformVariant.only(TargetPlatform.windows);
  final contents = List.generate(80, (i) => 'Line $i').join('\n');
  late QuillController controller;
  late FocusNode focus;
  late ScrollController scroll;

  setUp(() {
    controller = QuillController.basic()..document.insert(0, contents);
    focus = FocusNode();
    scroll = ScrollController();
  });

  Future<void> openAtBottom(
    WidgetTester tester, {
    FocusNode? other,
    FocusNode? after,
  }) async {
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    addTearDown(scroll.dispose);
    final editor = QuillEditor(
      controller: controller,
      focusNode: focus,
      scrollController: scroll,
      config: QuillEditorConfig(
        autoFocus: true,
        // An editable Quill normally consumes Tab for text or indentation.
        onKeyPressed: after == null
            ? null
            : (event, _) => event.logicalKey == LogicalKeyboardKey.tab
                  ? KeyEventResult.ignored
                  : null,
      ),
    );
    await tester.pumpWidget(
      QuillTestApp.withScaffold(
        Column(
          children: [
            if (other != null) Focus(focusNode: other, child: const SizedBox()),
            Expanded(child: editor),
            if (after != null) Focus(focusNode: after, child: const SizedBox()),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(focus.hasPrimaryFocus, isTrue);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(scroll.position.viewportDimension));
    expect(controller.selection.extentOffset, 0);
  }

  // Insert at the selection Quill actually sent to the platform text client.
  void typeX(WidgetTester tester) {
    final remote = TextEditingValue.fromJSON(
      tester.testTextInput.editingState!,
    );
    final selection = remote.selection;
    tester.testTextInput.updateEditingValue(
      remote.copyWith(
        text: remote.text.replaceRange(selection.start, selection.end, 'X'),
        selection: TextSelection.collapsed(offset: selection.start + 1),
      ),
    );
  }

  // Exercise the framework's public view-focus event path. Flutter chooses
  // which node to suspend and restore, as it does for a native view.
  Future<void> viewFocus(
    WidgetTester tester,
    ViewFocusState state, [
    ViewFocusDirection direction = ViewFocusDirection.undefined,
  ]) async {
    tester.binding.handleViewFocusChanged(
      ViewFocusEvent(
        viewId: tester.view.viewId,
        state: state,
        direction: direction,
      ),
    );
    await tester.pump();
    expect(focus.hasPrimaryFocus, state == ViewFocusState.focused);
  }

  bool caretIsVisible(WidgetTester tester) {
    final editor = tester
        .state<QuillRawEditorState>(find.byType(QuillRawEditor))
        .renderEditor;
    final center = editor
        .getLocalRectForCaret(controller.selection.extent)
        .center;
    return tester
        .getRect(find.byType(QuillEditor))
        .contains(editor.localToGlobal(center));
  }

  for (final direction in [
    ViewFocusDirection.forward,
    ViewFocusDirection.backward,
  ]) {
    testWidgets('directed view entry reveals the focused caret: $direction', (
      tester,
    ) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await openAtBottom(tester);
      expect(caretIsVisible(tester), isFalse);
      await viewFocus(tester, ViewFocusState.unfocused);
      await viewFocus(tester, ViewFocusState.focused, direction);
      await tester.pumpAndSettle();
      expect(controller.selection, const TextSelection.collapsed(offset: 0));
      expect(caretIsVisible(tester), isTrue);
    }, variant: windows);
  }

  testWidgets(
    'a directional event during application restoration preserves scroll',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await openAtBottom(tester);
      final bottom = scroll.offset;
      await viewFocus(tester, ViewFocusState.unfocused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      // Deliver the host's event before Flutter applies the restored focus.
      await viewFocus(
        tester,
        ViewFocusState.focused,
        ViewFocusDirection.forward,
      );
      await tester.pumpAndSettle();
      expect(controller.selection.extentOffset, 0);
      expect(scroll.offset, bottom);
    },
    variant: windows,
  );

  testWidgets(
    'directional notifications cannot retarget a passive view entry',
    (tester) async {
      await openAtBottom(tester);
      final bottom = scroll.offset;
      await viewFocus(tester, ViewFocusState.unfocused);
      void enter(int viewId, ViewFocusDirection direction) {
        tester.binding.handleViewFocusChanged(
          ViewFocusEvent(
            viewId: viewId,
            state: ViewFocusState.focused,
            direction: direction,
          ),
        );
      }

      // Deliver the foreign notification and the late acknowledgement before
      // focus moves off the root. Only the first entry for this view counts.
      enter(tester.view.viewId + 1, ViewFocusDirection.backward);
      enter(tester.view.viewId, ViewFocusDirection.undefined);
      enter(tester.view.viewId, ViewFocusDirection.forward);
      await tester.pumpAndSettle();
      expect(focus.hasPrimaryFocus, isTrue);
      expect(controller.selection.extentOffset, 0);
      expect(scroll.offset, bottom);
    },
    variant: windows,
  );

  testWidgets('view inset changes only reveal the focused editor', (
    tester,
  ) async {
    final other = FocusNode();
    addTearDown(other.dispose);
    addTearDown(tester.view.resetViewInsets);
    await openAtBottom(tester, other: other);
    other.requestFocus();
    await tester.pumpAndSettle();
    expect(other.hasPrimaryFocus, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(caretIsVisible(tester), isFalse);
    focus.requestFocus();
    await tester.pumpAndSettle();
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(caretIsVisible(tester), isFalse);
    tester.view.viewInsets = const FakeViewPadding(bottom: 200);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(caretIsVisible(tester), isTrue);
  }, variant: windows);

  testWidgets('Tab and Shift+Tab back into the editor reveal the caret', (
    tester,
  ) async {
    final before = FocusNode();
    final after = FocusNode();
    addTearDown(before.dispose);
    addTearDown(after.dispose);
    await openAtBottom(tester, other: before, after: after);
    Future<void> tab({required bool reverse}) async {
      if (reverse) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      if (reverse) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
    }

    for (final reverse in [false, true]) {
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(caretIsVisible(tester), isFalse);
      await tab(reverse: reverse);
      expect((reverse ? before : after).hasPrimaryFocus, isTrue);
      await tab(reverse: !reverse);
      expect(focus.hasPrimaryFocus, isTrue);
      expect(caretIsVisible(tester), isTrue);
      expect(controller.selection.extentOffset, 0);
    }
    expect(controller.document.toPlainText(), '$contents\n');
  }, variant: windows);

  testWidgets('restoring view focus preserves scroll and the offscreen caret', (
    tester,
  ) async {
    await openAtBottom(tester);
    final bottom = scroll.offset;
    final offsets = <double>[];
    scroll.addListener(() => offsets.add(scroll.offset));
    await viewFocus(tester, ViewFocusState.unfocused);
    await viewFocus(tester, ViewFocusState.focused);
    await tester.pumpAndSettle();
    expect(scroll.offset, bottom);
    expect(offsets, isEmpty);
    expect(controller.selection, const TextSelection.collapsed(offset: 0));
    expect(tester.testTextInput.hasAnyClients, isTrue);

    typeX(tester);
    await tester.pumpAndSettle();
    expect(controller.document.toPlainText(), 'X$contents\n');
    expect(controller.selection.extentOffset, 1);
    expect(scroll.offset, lessThan(scroll.position.viewportDimension));

    scroll.jumpTo(bottom);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(controller.selection.extentOffset, 2);
    expect(scroll.offset, lessThan(scroll.position.viewportDimension));
  }, variant: windows);

  testWidgets('a mouse click on the final character survives view restoration', (
    tester,
  ) async {
    await openAtBottom(tester);
    final bottom = scroll.offset;
    final raw = tester.state<QuillRawEditorState>(find.byType(QuillRawEditor));
    final editor = raw.renderEditor;
    final last = TextPosition(offset: contents.length);
    final end = editor.getLocalRectForCaret(last);
    // The trailing half of the final glyph places the caret just after it.
    final target = editor.localToGlobal(end.center - const Offset(1, 0));
    expect(editor.getPositionForOffset(target).offset, last.offset);
    await viewFocus(tester, ViewFocusState.unfocused);
    await viewFocus(tester, ViewFocusState.focused);
    final mouse = await tester.startGesture(
      target,
      kind: PointerDeviceKind.mouse,
    );
    // Give the focus callback and any resulting scroll animation a frame before
    // releasing the button at the same screen coordinate.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final positionAtRelease = editor.getPositionForOffset(target);
    await mouse.up();
    await tester.pumpAndSettle();
    expect(positionAtRelease.offset, last.offset);
    expect(controller.selection.extentOffset, last.offset);
    expect(scroll.offset, bottom);
    expect(tester.testTextInput.editingState!['selectionExtent'], last.offset);
    expect(controller.document.toPlainText(), '$contents\n');
    typeX(tester);
    await tester.pumpAndSettle();
    expect(controller.document.toPlainText(), '${contents}X\n');
    expect(controller.selection.extentOffset, last.offset + 1);
  }, variant: windows);

  testWidgets('an unchanged selection while inactive does not scroll on resume', (
    tester,
  ) async {
    await openAtBottom(tester);
    final bottom = scroll.offset;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    // Inject an unchanged notification just before the framework restores focus.
    controller.updateSelection(controller.selection, ChangeSource.local);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(focus.hasPrimaryFocus, isTrue);
    expect(scroll.offset, bottom);
    expect(controller.selection.extentOffset, 0);
    expect(tester.testTextInput.editingState!['selectionExtent'], 0);
  }, variant: windows);

  testWidgets('focus transferred to another control ends view restoration', (
    tester,
  ) async {
    final other = FocusNode();
    addTearDown(other.dispose);
    await openAtBottom(tester, other: other);
    await viewFocus(tester, ViewFocusState.unfocused);
    other.requestFocus();
    await tester.pump();
    expect(other.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focus.hasPrimaryFocus, isTrue);
    expect(scroll.offset, lessThan(scroll.position.viewportDimension));
    expect(controller.selection.extentOffset, 0);
  }, variant: windows);

  testWidgets(
    'an outstanding automatic reveal does not run in an inactive view',
    (tester) async {
      await openAtBottom(tester);
      final bottom = scroll.offset;
      controller.updateSelection(controller.selection, ChangeSource.local);
      // Suspend focus before the scheduled post-frame reveal can run.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();
      expect(focus.hasFocus, isFalse);
      expect(scroll.offset, bottom);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(focus.hasPrimaryFocus, isTrue);
      expect(scroll.offset, bottom);
    },
    variant: windows,
  );

  testWidgets('restored selection supports replacement and rich-text history', (
    tester,
  ) async {
    await openAtBottom(tester);
    controller
      ..formatText(0, 4, Attribute.bold)
      ..updateSelection(
        const TextSelection(baseOffset: 1, extentOffset: 3),
        ChangeSource.local,
      );
    await tester.pumpAndSettle();
    final original = controller.document.toDelta();
    controller.document.history.clear();
    final bottom = scroll.position.maxScrollExtent;
    scroll.jumpTo(bottom);
    await tester.pump();
    await viewFocus(tester, ViewFocusState.unfocused);
    await viewFocus(tester, ViewFocusState.focused);
    await tester.pumpAndSettle();
    expect(scroll.offset, bottom);
    expect(tester.testTextInput.editingState!['selectionBase'], 1);
    expect(tester.testTextInput.editingState!['selectionExtent'], 3);
    typeX(tester);
    await tester.pumpAndSettle();
    expect(controller.document.toPlainText(), 'LX${contents.substring(3)}\n');
    expect(
      controller.document.collectStyle(0, 2).attributes['bold'],
      Attribute.bold,
    );
    final edited = controller.document.toDelta();
    controller.undo();
    await tester.pumpAndSettle();
    expect(controller.document.toDelta(), original);
    controller.redo();
    await tester.pumpAndSettle();
    expect(controller.document.toDelta(), edited);
    scroll.jumpTo(bottom);
    await tester.pump();
    tester
        .state<QuillRawEditorState>(find.byType(QuillRawEditor))
        .bringIntoView(const TextPosition(offset: 0));
    await tester.pumpAndSettle();
    expect(scroll.offset, lessThan(scroll.position.viewportDimension));
  }, variant: windows);
}
