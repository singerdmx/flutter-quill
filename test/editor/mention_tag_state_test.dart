import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/src/editor/config/events/mention_tag_handlers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('config updates preserve active tag selection state', () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    controller.replaceText(
      0,
      0,
      '#Demo Tes',
      const TextSelection.collapsed(offset: 9),
    );

    final state = MentionTagState(
      config: MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
      controller: controller,
    );

    state.showOverlay(false, 0, 'Demo Tes', tagTrigger: '#');

    state.updateConfig(
      MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
    );

    state.overlayWidget?.onSelectTag(
      const TagItem(id: '1', name: 'Demo Test'),
    );

    expect(controller.document.toPlainText(), '#Demo Test \n');
    final tag =
        controller.document.collectStyle(0, 10).attributes[Attribute.tag.key];
    expect(tag?.value?['color'], '#FF0000');
  });

  test('config updates preserve active mention selection style', () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    controller.replaceText(
      0,
      0,
      '@nooh',
      const TextSelection.collapsed(offset: 5),
    );

    final state = MentionTagState(
      config: MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
        defaultMentionColor: '#0080FF',
      ),
      controller: controller,
    );

    state.showOverlay(true, 0, 'nooh');

    state.updateConfig(
      MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
        defaultMentionColor: '#0080FF',
      ),
    );

    state.overlayWidget?.onSelectMention(
      const MentionItem(id: '1', name: 'Nooh Davis'),
    );

    final mention = controller.document
        .collectStyle(0, 11)
        .attributes[Attribute.mention.key];

    expect(controller.document.toPlainText(), '@Nooh Davis \n');
    expect(mention?.value?['color'], '#0080FF');
  });

  test('tag selection resolves from live caret/doc when hint position is stale',
      () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    controller.replaceText(
      0,
      0,
      '#ok',
      const TextSelection.collapsed(offset: 4),
    );

    final state = MentionTagState(
      config: MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
      controller: controller,
    );

    state.showOverlay(
      false,
      999,
      '',
      tagTrigger: '#',
    ); // invalid hint index; caret + backward scan still find '#'

    state.overlayWidget?.onSelectTag(
      const TagItem(id: '1', name: 'okay'),
    );

    expect(controller.document.toPlainText(), '#okay \n');
  });

  test('tag selection uses document span when currentQuery lags editor', () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    controller.replaceText(
      0,
      0,
      '#abc',
      const TextSelection.collapsed(offset: 4),
    );

    final state = MentionTagState(
      config: MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
      controller: controller,
    );

    // Simulate debounce lag: document already has "abc" after # but state
    // still holds an older query length (would break if delete used that).
    state.showOverlay(false, 0, 'a', tagTrigger: '#');

    state.overlayWidget?.onSelectTag(
      const TagItem(id: '1', name: 'Alpha'),
    );

    expect(controller.document.toPlainText(), '#Alpha \n');
    final tag =
        controller.document.collectStyle(0, 6).attributes[Attribute.tag.key];
    expect(tag?.value?['name'], 'Alpha');
  });

  test('config updates do not refresh an active overlay', () {
    final controller = QuillController.basic();
    addTearDown(controller.dispose);

    var visibilityNotifications = 0;
    final state = MentionTagState(
      config: MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
      controller: controller,
      onVisibilityChanged: (_, __, ___, ____) {
        visibilityNotifications++;
      },
    );

    state.showOverlay(true, 0, 'user');
    expect(visibilityNotifications, 1);

    state.updateConfig(
      MentionTagConfig(
        mentionSearch: (_) async => const [],
        tagSearch: (_) async => const [],
        dollarSearch: (_) async => const [],
      ),
    );

    expect(visibilityNotifications, 1);
  });
}
