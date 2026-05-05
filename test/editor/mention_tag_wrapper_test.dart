import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'MentionTagWrapper does not call mentionSearch after hashtag trailing space',
      (tester) async {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    var mentionSearchCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MentionTagWrapper(
            controller: controller,
            config: MentionTagConfig(
              mentionSearch: (_) async {
                mentionSearchCalls++;
                return const [];
              },
              tagSearch: (_) async => const [],
              dollarSearch: (_) async => const [],
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    controller.replaceText(
      0,
      0,
      '@john #dart ',
      const TextSelection.collapsed(offset: 12),
    );
    await tester.pump();
    mentionSearchCalls = 0;

    // Mimic selected tag insertion path where the tag token is already
    // formatted, then a trailing space exists.
    final tagStart = '@john '.length;
    controller.formatText(
      tagStart,
      '#dart'.length,
      TagAttribute(value: {'id': '1', 'name': 'dart', 'color': '#0000FF'}),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(mentionSearchCalls, 0);
  });
}
