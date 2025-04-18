import 'package:flutter/material.dart';
import 'package:flutter_quill/src/common/utils/link_validator.dart';
import 'package:flutter_quill/src/controller/quill_controller.dart';
import 'package:flutter_quill/src/l10n/generated/quill_localizations.dart';

import 'package:flutter_quill/src/toolbar/buttons/link_style/link_dialog.dart';
import 'package:flutter_quill/src/toolbar/buttons/link_style/link_style_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../common/utils/quill_test_app.dart';

void main() {
  late QuillController controller;

  setUp(() => controller = QuillController.basic());
  tearDown(() => controller.dispose());

  testWidgets('allows to insert valid links', (tester) async {
    late FlutterQuillLocalizations loc;
    await tester.pumpWidget(
      QuillTestApp.withScaffold(
        QuillToolbarLinkStyleButton(controller: controller),
        onLocalizationsAvailable: (quillLocalizations) =>
            loc = quillLocalizations,
      ),
    );
    expect(find.byType(QuillToolbarLinkStyleButton), findsOneWidget);

    for (final linkPrefix in LinkValidator.linkPrefixes) {
      await tester.tap(find.byType(QuillToolbarLinkStyleButton));
      await tester.pumpAndSettle();

      expect(find.byType(LinkDialog), findsOne);

      await tester.enterText(
        find.widgetWithText(TextFormField, loc.text),
        'Example',
      );

      final link = '${linkPrefix}example';
      await tester.enterText(
        find.widgetWithText(TextFormField, loc.link),
        link,
      );

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(LinkDialog)) as LinkDialogState;
      expect(state.canPress(), true);

      final okButtonFinder = find.widgetWithText(TextButton, loc.ok);
      expect(okButtonFinder, findsOne);

      final okButton = tester.widget<TextButton>(okButtonFinder);
      expect(okButton.onPressed, isNotNull);

      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(LinkDialog), findsNothing);
    }
  });

  testWidgets('ok button is disabled for invalid links', (tester) async {
    late FlutterQuillLocalizations loc;
    await tester.pumpWidget(
      QuillTestApp.withScaffold(
        QuillToolbarLinkStyleButton(controller: controller),
        onLocalizationsAvailable: (quillLocalizations) =>
            loc = quillLocalizations,
      ),
    );
    expect(find.byType(QuillToolbarLinkStyleButton), findsOneWidget);

    await tester.tap(find.byType(QuillToolbarLinkStyleButton));
    await tester.pumpAndSettle();

    expect(find.byType(LinkDialog), findsOne);

    await tester.enterText(
      find.widgetWithText(TextFormField, loc.text),
      'Example',
    );

    const link = 'example invalid link';
    await tester.enterText(
      find.widgetWithText(TextFormField, loc.link),
      link,
    );

    await tester.pumpAndSettle();

    final state = tester.state(find.byType(LinkDialog)) as LinkDialogState;
    expect(state.canPress(), false);

    final okButtonFinder = find.widgetWithText(TextButton, loc.ok);
    expect(okButtonFinder, findsOne);

    final okButton = tester.widget<TextButton>(okButtonFinder);
    expect(okButton.onPressed, isNull);

    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LinkDialog), findsOne);
  });
}
