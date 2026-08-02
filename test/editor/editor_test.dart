import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/l10n/extensions/localizations_ext.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuillController controller;
  var didCopy = false;

  setUp(() {
    controller = QuillController.basic();
  });

  tearDown(() {
    controller.dispose();
  });

  group('QuillEditor', () {
    testWidgets('Keyboard entered text is stored in document', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(),
          ),
        ),
      );
      await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

      expect(controller.document.toPlainText(), 'test\n');
    });

    testWidgets('passes the configured cursor width to the raw editor', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(cursorWidth: 1),
          ),
        ),
      );

      final rawEditor = tester.widget<QuillRawEditor>(
        find.byType(QuillRawEditor),
      );
      expect(rawEditor.config.cursorStyle.width, 1);
    });

    testWidgets('passes every configured cursor dimension to the raw editor', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(
              cursorWidth: 1,
              cursorHeight: 17,
              cursorRadius: Radius.zero,
              cursorOffset: Offset.zero,
              cursorOpacityAnimates: true,
              paintCursorAboveText: false,
            ),
          ),
        ),
      );

      final style = tester
          .widget<QuillRawEditor>(find.byType(QuillRawEditor))
          .config
          .cursorStyle;
      expect(style.width, 1);
      expect(style.height, 17);
      expect(style.radius, Radius.zero);
      expect(style.offset, Offset.zero);
      expect(style.opacityAnimates, isTrue);
      expect(style.paintAboveText, isFalse);
    });

    testWidgets('keeps the existing cursor width default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor.basic(
            controller: controller,
            config: const QuillEditorConfig(),
          ),
        ),
      );

      final rawEditor = tester.widget<QuillRawEditor>(
        find.byType(QuillRawEditor),
      );
      expect(rawEditor.config.cursorStyle.width, 2);
    });

    test('copyWith preserves and updates every cursor dimension', () {
      const config = QuillEditorConfig(
        cursorWidth: 1,
        cursorHeight: 17,
        cursorRadius: Radius.circular(3),
        cursorOffset: Offset(4, 5),
        cursorOpacityAnimates: true,
      );

      expect(config.copyWith().cursorWidth, 1);
      expect(config.copyWith().cursorHeight, 17);
      expect(config.copyWith().cursorRadius, const Radius.circular(3));
      expect(config.copyWith().cursorOffset, const Offset(4, 5));
      expect(config.copyWith().cursorOpacityAnimates, isTrue);

      final nullArgumentsPreserveExistingValues = config.copyWith(
        cursorHeight: null,
        cursorRadius: null,
        cursorOffset: null,
        cursorOpacityAnimates: null,
      );
      expect(nullArgumentsPreserveExistingValues.cursorHeight, 17);
      expect(
        nullArgumentsPreserveExistingValues.cursorRadius,
        const Radius.circular(3),
      );
      expect(
        nullArgumentsPreserveExistingValues.cursorOffset,
        const Offset(4, 5),
      );
      expect(nullArgumentsPreserveExistingValues.cursorOpacityAnimates, isTrue);

      final updated = config.copyWith(
        cursorWidth: 3,
        cursorHeight: 19,
        cursorRadius: Radius.zero,
        cursorOffset: Offset.zero,
        cursorOpacityAnimates: false,
      );
      expect(updated.cursorWidth, 3);
      expect(updated.cursorHeight, 19);
      expect(updated.cursorRadius, Radius.zero);
      expect(updated.cursorOffset, Offset.zero);
      expect(updated.cursorOpacityAnimates, isFalse);
    });

    testWidgets('uses Flutter cursor defaults for each platform', (
      tester,
    ) async {
      Future<CursorStyle> cursorStyleFor(
        TargetPlatform platform, {
        double devicePixelRatio = 1,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(platform),
            theme: ThemeData(platform: platform),
            home: MediaQuery(
              data: MediaQueryData(devicePixelRatio: devicePixelRatio),
              child: QuillEditor.basic(
                controller: controller,
                config: const QuillEditorConfig(),
              ),
            ),
          ),
        );
        return tester
            .widget<QuillRawEditor>(find.byType(QuillRawEditor))
            .config
            .cursorStyle;
      }

      final macOS = await cursorStyleFor(
        TargetPlatform.macOS,
        devicePixelRatio: 2,
      );
      expect(macOS.radius, const Radius.circular(2));
      expect(macOS.platform, TargetPlatform.macOS);
      expect(macOS.offset, const Offset(-1, 0));
      expect(macOS.opacityAnimates, isFalse);
      expect(macOS.paintAboveText, isTrue);

      final iOS = await cursorStyleFor(TargetPlatform.iOS);
      expect(iOS.radius, const Radius.circular(2));
      expect(iOS.platform, TargetPlatform.iOS);
      expect(iOS.offset, const Offset(-2, 0));
      expect(iOS.opacityAnimates, isTrue);
      expect(iOS.paintAboveText, isTrue);

      for (final platform in <TargetPlatform>[
        TargetPlatform.android,
        TargetPlatform.fuchsia,
        TargetPlatform.linux,
        TargetPlatform.windows,
      ]) {
        final style = await cursorStyleFor(platform);
        expect(style.platform, platform, reason: '$platform geometry');
        expect(style.radius, isNull, reason: '$platform radius');
        expect(style.offset, isNull, reason: '$platform offset');
        expect(style.opacityAnimates, isFalse, reason: '$platform opacity');
        expect(style.paintAboveText, isFalse, reason: '$platform paint order');
      }
    });

    testWidgets('updates cursor geometry when the configuration changes', (
      tester,
    ) async {
      Widget build(QuillEditorConfig config) => MaterialApp(
        theme: ThemeData(platform: TargetPlatform.macOS),
        home: QuillEditor.basic(controller: controller, config: config),
      );

      await tester.pumpWidget(
        build(
          const QuillEditorConfig(
            cursorWidth: 1,
            cursorHeight: 12,
            cursorRadius: Radius.zero,
            cursorOffset: Offset.zero,
            cursorOpacityAnimates: true,
          ),
        ),
      );

      CursorStyle style() => tester
          .widget<QuillRawEditor>(find.byType(QuillRawEditor))
          .config
          .cursorStyle;

      expect(style().width, 1);
      expect(style().height, 12);
      expect(style().offset, Offset.zero);

      await tester.pumpWidget(
        build(
          const QuillEditorConfig(
            cursorWidth: 3,
            cursorHeight: 20,
            cursorRadius: Radius.circular(4),
            cursorOffset: Offset(5, 6),
            cursorOpacityAnimates: false,
          ),
        ),
      );

      expect(style().width, 3);
      expect(style().height, 20);
      expect(style().radius, const Radius.circular(4));
      expect(style().offset, const Offset(5, 6));
      expect(style().opacityAnimates, isFalse);

      await tester.pumpWidget(build(const QuillEditorConfig()));

      expect(style().width, 2);
      expect(style().height, isNull);
      expect(style().radius, const Radius.circular(2));
      expect(style().offset, Offset(-2 / tester.view.devicePixelRatio, 0));
      expect(style().opacityAnimates, isFalse);
    });

    testWidgets('insertContent is handled correctly', (tester) async {
      String? latestUri;
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor(
            focusNode: FocusNode(),
            scrollController: ScrollController(),
            controller: controller,
            config: QuillEditorConfig(
              autoFocus: true,
              expands: true,
              contentInsertionConfiguration: ContentInsertionConfiguration(
                onContentInserted: (content) {
                  latestUri = content.uri;
                },
                allowedMimeTypes: <String>['image/gif'],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(QuillEditor));
      await tester.quillEnterText(find.byType(QuillEditor), 'test\n');
      await tester.idle();

      const uri =
          'content://com.google.android.inputmethod.latin.fileprovider/test.gif';
      final messageBytes = const JSONMessageCodec().encodeMessage(<
        String,
        dynamic
      >{
        'args': <dynamic>[
          -1,
          'TextInputAction.commitContent',
          jsonDecode(
            '{"mimeType": "image/gif", "data": [0,1,0,1,0,1,0,0,0], "uri": "$uri"}',
          ),
        ],
        'method': 'TextInputClient.performAction',
      });

      Object? error;
      try {
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/textinput',
          messageBytes,
          (_) {},
        );
      } catch (e) {
        error = e;
      }
      expect(error, isNull);
      expect(latestUri, equals(uri));
    });

    Widget customBuilder(BuildContext context, QuillRawEditorState state) {
      return AdaptiveTextSelectionToolbar(
        anchors: state.contextMenuAnchors,
        children: [
          Container(
            height: 50,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    didCopy = true;
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),
        ],
      );
    }

    testWidgets('custom context menu builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor(
            focusNode: FocusNode(),
            scrollController: ScrollController(),
            controller: controller,
            config: QuillEditorConfig(
              autoFocus: true,
              expands: true,
              contextMenuBuilder: customBuilder,
            ),
          ),
        ),
      );

      // Long press to show menu
      await tester.longPress(find.byType(QuillEditor));
      await tester.pumpAndSettle();

      // Verify custom widget shows
      expect(find.byIcon(Icons.copy), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy));
      expect(didCopy, isTrue);
    });

    testWidgets(
      'QuillEditorOpenSearchAction should not throw an exception when the required localization delegates are provided',
      (tester) async {
        final editorFocusNode = FocusNode();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            home: QuillEditor.basic(
              controller: controller,
              config: const QuillEditorConfig(),
              focusNode: editorFocusNode,
            ),
          ),
        );
        // Required, otherwise the action shortcuts won't be invoked.
        editorFocusNode.requestFocus();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.control);

        await tester.pump();

        final exception = tester.takeException();
        expect(
          exception,
          isNot(isInstanceOf<MissingFlutterQuillLocalizationException>()),
        );

        expect(exception, isNull);
      },
    );

    testWidgets(
      'should throw MissingFlutterQuillLocalizationException if the delegate not provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) => Text(context.loc.font)),
          ),
        );

        final exception = tester.takeException();

        expect(exception, isNotNull);
        expect(exception, isA<MissingFlutterQuillLocalizationException>());
      },
    );

    testWidgets(
      'should not throw MissingFlutterQuillLocalizationException if the delegate is provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates:
                FlutterQuillLocalizations.localizationsDelegates,
            home: Builder(builder: (context) => Text(context.loc.font)),
          ),
        );

        final exception = tester.takeException();

        expect(exception, isNull);
        expect(
          exception,
          isNot(isA<MissingFlutterQuillLocalizationException>()),
        );
      },
    );

    testWidgets(
      'should throw MissingFlutterQuillLocalizationException if the delegate is not provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(builder: (context) => Text(context.loc.font)),
          ),
        );

        final exception = tester.takeException();

        expect(exception, isNotNull);
        expect(exception, isA<MissingFlutterQuillLocalizationException>());
      },
    );
  });
}
