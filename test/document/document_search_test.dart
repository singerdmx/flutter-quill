import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';

class TestTimeStampEmbed extends Embeddable {
  const TestTimeStampEmbed(
    String value,
  ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';
}

class TestTimeStampEmbedBuilderWidget extends EmbedBuilder {
  const TestTimeStampEmbedBuilderWidget();

  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data.split(' ')[0]; // return date component
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Text(embedContext.node.value.data);
  }
}

class TestUnknownEmbedBuilder extends EmbedBuilder {
  const TestUnknownEmbedBuilder();

  @override
  String get key => 'unknown';

  @override
  String toPlainText(Embed node) {
    return node.value.data.toString().substring(0, 5);
  }

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    return Text(embedContext.node.value.data);
  }
}

void main() {
  group('search plain', () {
    test('search plain', () {
      final delta = Delta()
        ..insert('Abc de\nfGhi')
        ..insert('kl', {'bold': true})
        ..insert('demnoDe\n match whole word who\n');
      final document = Document.fromDelta(delta);

      expect(document.search('de'), [4, 13, 18]);
      expect(document.search('lde'), [12]);
      expect(document.search('a'), [0, 23]);

      expect(document.search('de', caseSensitive: true), [4, 13]);
      expect(document.search('De', caseSensitive: true), [18]);

      expect(document.search('who'), [28, 39]);
      expect(document.search('whole', wholeWord: true), [28]);
      expect(document.search('who', wholeWord: true), [39]);
    });

    test('search embed', () {
      final delta = Delta()
        ..insert('Test ')
        ..insert({
          'image': 'https://unknown08.com/7900d52.png'
        }, {
          'width': '230',
          'style': {'display': 'block', 'margin': 'auto'}
        })
        ..insert('\n')
        ..insert({'timeStamp': '2024-08-03 18:03:37.790068'})
        ..insert('\n');
      final document = Document.fromDelta(delta);

      /// Default does not search embeds
      expect(document.search('2024'), [], reason: 'Does not search embeds');

      /// Test rawData mode
      document.searchConfig =
          const QuillSearchConfig(searchEmbedMode: SearchEmbedMode.rawData);
      expect(document.search('18'), [7], reason: 'raw data finds timeStamp');
      expect(document.search('d52'), [5], reason: 'raw data finds image');
      expect(document.search('08'), [5, 7],
          reason: 'raw data finds both embeds');
      //
      document.searchConfig =
          const QuillSearchConfig(searchEmbedMode: SearchEmbedMode.plainText);
      expect(document.search('2024'), [], reason: 'No embed builders');

      /// Test plainText mode
      document
        ..searchConfig =
            const QuillSearchConfig(searchEmbedMode: SearchEmbedMode.plainText)
        ..embedBuilders = [
          const TestTimeStampEmbedBuilderWidget(),
        ];
      expect(document.search('2024'), [7],
          reason: 'timeStamp embed builder overrides toPlainText');
      expect(document.search('18'), [],
          reason: 'timeStamp overrides toPlainText returns date not time');
      expect(document.search('08'), [7],
          reason: 'image does not override toPlainText');

      /// Test unknownEmbedBuilder
      document
        ..searchConfig =
            const QuillSearchConfig(searchEmbedMode: SearchEmbedMode.plainText)
        ..embedBuilders = [
          const TestTimeStampEmbedBuilderWidget(),
        ]
        ..unknownEmbedBuilder = const TestUnknownEmbedBuilder();
      expect(document.search('7900'), [],
          reason:
              'image not found because unknown returns first 5 chars of rawData');
      expect(document.search('https'), [5],
          reason:
              'image found because unknown returns first 5 chars of rawData');
      expect(document.search('http'), [5]);
    });
    testWidgets(
        'the $QuillEditorConfig inside the $QuillController should not be null after the $QuillEditor set it to support search within embed objects',
        (tester) async {
      final controller = QuillController.basic();

      // To support search within embed objects, we store the editor config
      // internally inside the controller, it's null and expected to be not
      // null after connecting the controller with the QuillEditor
      // as the editor widget will update it. See https://github.com/singerdmx/flutter-quill/pull/2090.
      // The required properties will be passed to the Document from the QuillController.

      // Null initially before connecting the controller with the QuillEditor widget
      expect(controller.editorConfig, null);

      const editorConfig = QuillEditorConfig(
        searchConfig:
            QuillSearchConfig(searchEmbedMode: SearchEmbedMode.rawData),
        embedBuilders: [],
      );
      await tester.pumpWidget(MaterialApp(
        home: QuillEditor.basic(
          controller: controller,
          config: editorConfig,
        ),
      ));
      expect(controller.editorConfig, isNotNull);
      expect(controller.editorConfig, editorConfig);
    });
    testWidgets(
      'the $QuillController should set the required properties to the $Document to support search within embed objects',
      (tester) async {
        final controller = QuillController.basic();
        // To support search within embed objects, we store the editor config
        // internally inside the controller, it's null and expected to be not
        // null after connecting the controller with the QuillEditor
        // as the editor widget will update it. See https://github.com/singerdmx/flutter-quill/pull/2090.
        // The required properties will be passed to the Document from the QuillController.

        // Null initially before connecting the controller with the QuillEditor widget
        expect(controller.document.embedBuilders, null);
        expect(controller.document.unknownEmbedBuilder, null);
        expect(controller.document.searchConfig, null);

        const editorConfig = QuillEditorConfig(
          searchConfig:
              QuillSearchConfig(searchEmbedMode: SearchEmbedMode.rawData),
          embedBuilders: [],
          unknownEmbedBuilder: TestUnknownEmbedBuilder(),
        );
        await tester.pumpWidget(MaterialApp(
          home: QuillEditor.basic(
            controller: controller,
            config: editorConfig,
          ),
        ));

        expect(controller.document.embedBuilders, editorConfig.embedBuilders);
        expect(controller.document.unknownEmbedBuilder,
            editorConfig.unknownEmbedBuilder);
        expect(controller.document.searchConfig, editorConfig.searchConfig);
      },
    );
  });
}
