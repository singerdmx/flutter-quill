import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/src/common/utils/element_utils/element_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/config/image_config.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_menu.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_save_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../quill_test_app.dart';

void main() {
  group('$ImageOptionsMenu', () {
    test('prefersGallerySave defaults to true', () {
      final widget = ImageOptionsMenu(
        controller: FakeQuillController(),
        config: const QuillEditorImageEmbedConfig(),
        imageProvider: FakeImageProvider(),
        imageSource: 'imageSource',
        readOnly: true,
        imageSize: const ElementSize(200, 300),
      );
      expect(
        widget.prefersGallerySave,
        isTrue,
        reason:
            'The default of prefersGallerySave should be true for backward compatibility',
      );
    });
    group('save image', () {
      late MockImageSaver mockImageSaver;
      final QuillController controller = FakeQuillController();

      setUp(() {
        mockImageSaver = MockImageSaver();
        ImageSaver.instance = mockImageSaver;
      });

      setUpAll(() {
        registerFallbackValue(FakeImageProvider());
      });

      Future<void> pumpTargetWidget(
        WidgetTester tester, {
        String imageSource = 'http://flutter-quill.org/image.png',
        ImageProvider? imageProvider,
        bool prefersGallerySave = false,
      }) async {
        await tester.pumpWidget(QuillTestApp.withScaffold(ImageOptionsMenu(
          controller: controller,
          config: const QuillEditorImageEmbedConfig(),
          imageProvider: imageProvider ?? FakeImageProvider(),
          imageSource: imageSource,
          readOnly: true,
          imageSize: const ElementSize(200, 300),
          prefersGallerySave: prefersGallerySave,
        )));
      }

      Finder findTargetWidget() {
        final saveButtonFinder = find.widgetWithIcon(ListTile, Icons.save);
        expect(saveButtonFinder, findsOneWidget);
        return saveButtonFinder;
      }

      void mockSaveImageResult(SaveImageResult? result) => when(
            () => mockImageSaver.saveImage(
              imageUrl: any(named: 'imageUrl'),
              imageProvider: any(named: 'imageProvider'),
              prefersGallerySave: any(named: 'prefersGallerySave'),
            ),
          ).thenAnswer((_) async => result);

      void mockSaveImageThrows(Exception exception) => when(
            () => mockImageSaver.saveImage(
              imageUrl: any(named: 'imageUrl'),
              imageProvider: any(named: 'imageProvider'),
              prefersGallerySave: any(named: 'prefersGallerySave'),
            ),
          ).thenThrow(exception);

      Future<void> tapTargetWidget(WidgetTester tester) async {
        await tester.tap(findTargetWidget());
        await tester.pump();
      }

      testWidgets('calls saveImage from $ImageSaver', (tester) async {
        mockSaveImageResult(null);

        await pumpTargetWidget(tester);

        await tapTargetWidget(tester);

        verify(
          () => mockImageSaver.saveImage(
            imageUrl: any(named: 'imageUrl'),
            imageProvider: any(named: 'imageProvider'),
            prefersGallerySave: any(named: 'prefersGallerySave'),
          ),
        );
      });

      if (kIsWeb) {
        testWidgets(
          'shows a success message when the image is downloaded on the web.',
          (tester) async {
            mockSaveImageResult(const SaveImageResult(
                imageFilePath: null, isGallerySave: false));

            await pumpTargetWidget(tester);
            await tapTargetWidget(tester);

            final localizations =
                tester.localizationsFromElement(ImageOptionsMenu);

            expect(
              find.text(localizations.successImageDownloaded),
              findsOneWidget,
            );
          },
        );
      }

      testWidgets(
          'shows permission denied message only when permission is denied',
          (tester) async {
        mockSaveImageThrows(GalleryImageSaveAccessDeniedException());

        await pumpTargetWidget(tester);
        await tapTargetWidget(tester);

        final localizations = tester.localizationsFromElement(ImageOptionsMenu);

        expect(
          find.text(localizations.saveImagePermissionDenied),
          findsOneWidget,
        );
        expect(
          find.text(localizations.errorUnexpectedSavingImage),
          findsNothing,
        );
        expect(
          find.text(localizations.successImageDownloaded),
          findsNothing,
        );
        expect(
          find.text(localizations.successImageSavedGallery),
          findsNothing,
        );
        expect(
          find.text(localizations.successImageSaved),
          findsNothing,
        );
        expect(
          find.text(localizations.openFileLocation),
          findsNothing,
        );
        expect(
          find.text(localizations.openFile),
          findsNothing,
        );
        expect(
          find.text(localizations.openGallery),
          findsNothing,
        );
      });

      testWidgets('shows error message when saving fails', (tester) async {
        mockSaveImageResult(null);

        await pumpTargetWidget(tester);
        await tapTargetWidget(tester);

        final localizations = tester.localizationsFromElement(ImageOptionsMenu);

        expect(
          find.text(localizations.errorUnexpectedSavingImage),
          findsOneWidget,
        );

        verify(
          () => mockImageSaver.saveImage(
            imageUrl: any(named: 'imageUrl'),
            imageProvider: any(named: 'imageProvider'),
            prefersGallerySave: any(named: 'prefersGallerySave'),
          ),
        );
      });

      testWidgets('shows saved and open gallery on gallery save',
          (tester) async {
        mockSaveImageResult(const SaveImageResult(
            imageFilePath: 'path/to/file', isGallerySave: true));

        await pumpTargetWidget(tester);

        await tapTargetWidget(tester);

        final localizations = tester.localizationsFromElement(ImageOptionsMenu);

        expect(
          find.text(localizations.successImageSavedGallery),
          findsOneWidget,
        );

        expect(
          find.text(localizations.openGallery),
          findsOneWidget,
        );
      });

      for (final desktopPlatform in TargetPlatformVariant.desktop().values) {
        testWidgets(
            'shows saved success image and open file path action on ${desktopPlatform.name}',
            (tester) async {
          debugDefaultTargetPlatformOverride = desktopPlatform;

          const savedImagePath = 'path/to/file';
          mockSaveImageResult(const SaveImageResult(
              imageFilePath: savedImagePath, isGallerySave: false));

          await pumpTargetWidget(tester);
          await tapTargetWidget(tester);

          final localizations =
              tester.localizationsFromElement(ImageOptionsMenu);

          expect(
            find.text(localizations.successImageSaved),
            findsOneWidget,
          );

          expect(
            find.text(defaultTargetPlatform == TargetPlatform.macOS
                ? localizations.openFile
                : localizations.openFileLocation),
            findsOneWidget,
          );

          debugDefaultTargetPlatformOverride = null;
        });
      }

      for (final prefersGallerySave in {true, false}) {
        testWidgets(
            'passes the arguments correctly to saveImage from $ImageSaver when prefersGallerySave is $prefersGallerySave',
            (tester) async {
          mockSaveImageResult(
            const SaveImageResult(imageFilePath: null, isGallerySave: true),
          );

          const imageUrl = 'http://flutter-quill.org/image.webp';
          final imageProvider = AnotherFakeImageProvider();

          await pumpTargetWidget(
            tester,
            imageSource: imageUrl,
            prefersGallerySave: prefersGallerySave,
            imageProvider: imageProvider,
          );

          await tapTargetWidget(tester);

          verify(
            () => mockImageSaver.saveImage(
                imageUrl: imageUrl,
                imageProvider: imageProvider,
                prefersGallerySave: prefersGallerySave),
          ).called(1);
        });
      }

      testWidgets('throws $StateError when save result is not handled',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

        mockSaveImageResult(
            const SaveImageResult(imageFilePath: null, isGallerySave: false));

        Object? capturedException;

        await runZonedGuarded(() async {
          await pumpTargetWidget(tester);

          await tapTargetWidget(tester);
        }, (error, stackTrace) {
          capturedException = error;
        });

        expect(
            capturedException,
            isA<StateError>().having(
              (e) => e.message,
              'message',
              equals(
                  'Image save result is not handled on $defaultTargetPlatform'),
            ));

        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}

class MockImageSaver extends Mock implements ImageSaver {}

class FakeQuillController extends Fake implements QuillController {}

class FakeImageProvider extends ImageProvider {
  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async =>
      UnimplementedError('Fake implementation of $ImageProvider');
}

class AnotherFakeImageProvider extends ImageProvider {
  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async =>
      UnimplementedError('Another fake implementation of $ImageProvider');
}
