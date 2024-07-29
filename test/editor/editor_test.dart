import 'dart:convert' show jsonDecode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';
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
            // ignore: avoid_redundant_argument_values
            configurations: const QuillEditorConfigurations(
                // ignore: avoid_redundant_argument_values
                ),
          ),
        ),
      );
      await tester.quillEnterText(find.byType(QuillEditor), 'test\n');

      expect(controller.document.toPlainText(), 'test\n');
    });

    testWidgets('insertContent is handled correctly', (tester) async {
      String? latestUri;
      await tester.pumpWidget(
        MaterialApp(
          home: QuillEditor(
            focusNode: FocusNode(),
            scrollController: ScrollController(),
            controller: controller,
            configurations: QuillEditorConfigurations(
              // ignore: avoid_redundant_argument_values
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
      final messageBytes =
          const JSONMessageCodec().encodeMessage(<String, dynamic>{
        'args': <dynamic>[
          -1,
          'TextInputAction.commitContent',
          jsonDecode(
              '{"mimeType": "image/gif", "data": [0,1,0,1,0,1,0,0,0], "uri": "$uri"}'),
        ],
        'method': 'TextInputClient.performAction',
      });

      Object? error;
      try {
        await tester.binding.defaultBinaryMessenger
            .handlePlatformMessage('flutter/textinput', messageBytes, (_) {});
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
            // ignore: avoid_redundant_argument_values
            configurations: QuillEditorConfigurations(
              // ignore: avoid_redundant_argument_values
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
      'make sure QuillEditorOpenSearchAction does not throw an exception',
      (tester) async {
        final editorFocusNode = FocusNode();
        await tester.pumpWidget(
          MaterialApp(
            home: QuillEditor.basic(
              controller: controller,
              configurations: const QuillEditorConfigurations(),
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
          isNot(
            isInstanceOf<MissingFlutterQuillLocalizationException>(),
          ),
        );

        expect(exception, isNull);
      },
    );

    testWidgets(
      'should throw MissingFlutterQuillLocalizationException if the delegate not provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Text(context.loc.font),
            ),
          ),
        );

        final exception = tester.takeException();

        expect(exception, isNotNull);
        expect(
          exception,
          isA<MissingFlutterQuillLocalizationException>(),
        );
      },
    );

    testWidgets(
      'should not throw MissingFlutterQuillLocalizationException if the delegate is provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: FlutterQuillLocalizationsWidget(
              child: Builder(
                builder: (context) => Text(context.loc.font),
              ),
            ),
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
  });
}
