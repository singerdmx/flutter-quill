import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_quill_test/flutter_quill_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('$QuillEditor renders and handles input without crashing',
      (tester) async {
    // This test ensures that the QuillEditor can be created and accepts input
    // without crashing on any platform.
    //
    // Example fix: https://github.com/singerdmx/flutter-quill/pull/2579

    final controller = QuillController.basic();
    await tester.pumpWidget(MaterialApp(
      home: QuillEditor.basic(controller: controller),
    ));

    // Simulate text input to trigger user interactions.
    await tester.quillEnterText(find.byType(QuillEditor), 'sample text\n');

    controller.dispose();
  });
}
