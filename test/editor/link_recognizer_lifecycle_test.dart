import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill/src/editor/widgets/text/text_line.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/utils/quill_test_app.dart';

class _TrackingRecognizer extends TapGestureRecognizer {
  int disposals = 0;

  @override
  void dispose() {
    disposals++;
    super.dispose();
  }
}

class _InlineEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'box';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) =>
      const SizedBox(width: 16, height: 16);
}

TextSpan _textSpan(WidgetTester tester, String text) {
  final spans = <TextSpan>[];
  void visit(InlineSpan span) {
    if (span is TextSpan) {
      if (span.text == text) spans.add(span);
      span.children?.forEach(visit);
    }
  }

  for (final richText in tester.widgetList<RichText>(
    find.descendant(of: find.byType(TextLine), matching: find.byType(RichText)),
  )) {
    visit(richText.text);
  }
  return spans.single;
}

void main() {
  late QuillController controller;

  setUp(() {
    controller = QuillController(
      document: Document.fromDelta(
        Delta()
          ..insert('link', {'link': 'https://example.com'})
          ..insert(' tail\n'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  });

  tearDown(() => controller.dispose());

  Widget editor({QuillEditorConfig config = const QuillEditorConfig()}) =>
      QuillTestApp.withScaffold(
        QuillEditor.basic(controller: controller, config: config),
      );

  void deleteLeaf(int offset) {
    controller.compose(
      Delta()
        ..retain(offset)
        ..delete(4),
      controller.selection,
      ChangeSource.remote,
    );
  }

  for (final mutation in ['remove link', 'delete leaf', 'reformat leaf']) {
    testWidgets('$mutation disposes the old recognizer after rebuilding', (
      tester,
    ) async {
      final created = <_TrackingRecognizer>[];
      final observed = <Leaf>[];
      var taps = 0;
      await tester.pumpWidget(
        editor(
          config: QuillEditorConfig(
            customRecognizerBuilder: (attribute, node) {
              if (attribute.key != Attribute.link.key) return null;
              if (created.isNotEmpty) {
                expect(created.last.disposals, 0);
              }
              final recognizer = _TrackingRecognizer()..onTap = () => taps++;
              created.add(recognizer);
              observed.add(node);
              return recognizer;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final old = created.single;

      tester.element(find.byType(TextLine)).markNeedsBuild();
      await tester.pump();
      expect(created, [old]);
      old.onTap!();
      expect(taps, 1);

      switch (mutation) {
        case 'remove link':
          controller.formatText(0, 4, const LinkAttribute(null));
        case 'delete leaf':
          deleteLeaf(0);
        case 'reformat leaf':
          controller.formatText(0, 4, Attribute.bold);
      }
      await tester.pump();
      expect(old.disposals, 1);
      if (mutation == 'delete leaf') {
        expect(observed.first.parent, isNull);
      }
      if (mutation == 'reformat leaf') {
        expect(created, hasLength(2));
        expect(observed.last, same(observed.first));
        expect(_textSpan(tester, 'link').recognizer, same(created.last));
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(created.every((recognizer) => recognizer.disposals == 1), isTrue);
    });
  }

  testWidgets('inline embeds retain recognizers for actual document leaves', (
    tester,
  ) async {
    controller.document.insert(0, const BlockEmbed('box', ''));
    final created = <_TrackingRecognizer>[];
    Leaf? recognizedLeaf;
    await tester.pumpWidget(
      editor(
        config: QuillEditorConfig(
          embedBuilders: [_InlineEmbedBuilder()],
          customRecognizerBuilder: (attribute, node) {
            if (attribute.key != Attribute.link.key) return null;
            recognizedLeaf = node;
            final recognizer = _TrackingRecognizer();
            created.add(recognizer);
            return recognizer;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      recognizedLeaf,
      same(controller.document.querySegmentLeafNode(1).leaf),
    );
    tester.element(find.byType(TextLine)).markNeedsBuild();
    await tester.pump();
    expect(created, hasLength(1));
    expect(created.single.disposals, 0);
    deleteLeaf(1);
    await tester.pump();
    expect(created.single.disposals, 1);
  });

  testWidgets('queued tap cannot launch a removed or deleted link', (
    tester,
  ) async {
    final launched = <String>[];
    await tester.pumpWidget(
      editor(config: QuillEditorConfig(onLaunchUrl: launched.add)),
    );
    await tester.pumpAndSettle();
    final callback =
        (_textSpan(tester, 'link').recognizer! as TapGestureRecognizer).onTap!;
    controller.formatText(0, 4, const LinkAttribute(null));
    callback();
    expect(launched, isEmpty);
    await tester.pump();

    controller.formatText(0, 4, const LinkAttribute('https://example.com'));
    await tester.pump();
    final deletedCallback =
        (_textSpan(tester, 'link').recognizer! as TapGestureRecognizer).onTap!;
    deleteLeaf(0);
    deletedCallback();
    await tester.pump();
    expect(launched, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom non-link recognizers survive unchanged rebuilds', (
    tester,
  ) async {
    controller.document = Document.fromDelta(
      Delta()
        ..insert('@bob', {'mention': 'bob'})
        ..insert('\n'),
    );
    final created = <_TrackingRecognizer>[];
    var taps = 0;
    await tester.pumpWidget(
      editor(
        config: QuillEditorConfig(
          customRecognizerBuilder: (attribute, node) {
            if (attribute.key != 'mention') return null;
            final recognizer = _TrackingRecognizer()..onTap = () => taps++;
            created.add(recognizer);
            return recognizer;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var rebuild = 1; rebuild <= 3; rebuild++) {
      tester.element(find.byType(TextLine)).markNeedsBuild();
      await tester.pump();
      await tester.tapOnText(find.textRange.ofSubstring('@bob'));
      await tester.pump();
      expect(taps, rebuild);
      expect(created, hasLength(1));
      expect(created.single.disposals, 0);
      expect(_textSpan(tester, '@bob').mouseCursor, SystemMouseCursors.click);
    }
  });

  testWidgets('removing a link between pointer down and up is safe', (
    tester,
  ) async {
    final launched = <String>[];
    await tester.pumpWidget(
      editor(config: QuillEditorConfig(onLaunchUrl: launched.add)),
    );
    await tester.pumpAndSettle();
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(TextLine),
        matching: find.byType(RichText),
      ),
    );
    final box = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 4),
        )
        .single;
    final gesture = await tester.startGesture(
      paragraph.localToGlobal(box.toRect().center),
    );
    controller.formatText(0, 4, const LinkAttribute(null));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(launched, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retired tap cannot act on a replacement recognizer', (
    tester,
  ) async {
    final launched = <String>[];
    await tester.pumpWidget(
      editor(config: QuillEditorConfig(onLaunchUrl: launched.add)),
    );
    await tester.pumpAndSettle();
    final callback =
        (_textSpan(tester, 'link').recognizer! as TapGestureRecognizer).onTap!;
    controller.formatText(0, 4, Attribute.bold);
    await tester.pump();
    callback();
    expect(launched, isEmpty);
    (_textSpan(tester, 'link').recognizer! as TapGestureRecognizer).onTap!();
    expect(launched, ['https://example.com']);
  });

  for (final mutation in ['remove link', 'delete leaf', 'unmount editor']) {
    testWidgets('pending link menu ignores remove after $mutation', (
      tester,
    ) async {
      controller.readOnly = false;
      final action = Completer<LinkMenuAction>();
      await tester.pumpWidget(
        editor(
          config: QuillEditorConfig(
            linkActionPickerDelegate: (context, link, node) => action.future,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final recognizer =
          _textSpan(tester, 'link').recognizer! as LongPressGestureRecognizer;
      recognizer.onLongPress!();
      switch (mutation) {
        case 'remove link':
          controller.formatText(0, 4, const LinkAttribute(null));
        case 'delete leaf':
          deleteLeaf(0);
        case 'unmount editor':
          await tester.pumpWidget(const SizedBox.shrink());
      }
      await tester.pump();
      final delta = controller.document.toDelta();
      action.complete(LinkMenuAction.remove);
      await tester.pumpAndSettle();
      expect(controller.document.toDelta(), delta);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}
