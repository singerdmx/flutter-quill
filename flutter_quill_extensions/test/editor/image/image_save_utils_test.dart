import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/internal.dart';
import 'package:flutter_quill_extensions/src/common/utils/file_path_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_load_utils.dart';
import 'package:flutter_quill_extensions/src/editor/image/image_save_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const testImageExtensions = {'png', 'jpeg', 'jpg', 'gif'};

void main() {
  group('extractImageFileExtensionFromFileName', () {
    test('defaults to using png', () {
      expect(defaultImageFileExtension, equals('png'));
    });

    test('returns $defaultImageFileExtension when file name is null or empty',
        () {
      expect(extractImageFileExtensionFromFileName(null),
          equals(defaultImageFileExtension));
      expect(extractImageFileExtensionFromFileName(''),
          equals(defaultImageFileExtension));
    });

    test('returns $defaultImageFileExtension when file name does not have dot',
        () {
      expect(extractImageFileExtensionFromFileName('imagepng'),
          equals(defaultImageFileExtension));
      expect(extractImageFileExtensionFromFileName('image png'),
          equals(defaultImageFileExtension));
      expect(extractImageFileExtensionFromFileName('image'),
          equals(defaultImageFileExtension));
      expect(extractImageFileExtensionFromFileName('png'),
          equals(defaultImageFileExtension));
    });

    test('returns the file extension correctly', () {
      for (final fileExtension in testImageExtensions) {
        expect(extractImageFileExtensionFromFileName('image.$fileExtension'),
            equals(fileExtension));
      }
    });
  });
  group('extractImageFileNameFromFileName', () {
    test(
        'returns the file name without the extension when a valid name is given',
        () {
      expect(
          extractImageNameFromFileName('image.jpg', imageFileExtension: 'jpg'),
          'image');
    });

    test('returns null when the input is null or empty', () {
      expect(extractImageNameFromFileName(null, imageFileExtension: 'jpg'),
          isNull);
      expect(
          extractImageNameFromFileName('', imageFileExtension: 'jpg'), isNull);
    });

    test('returns the image name correctly', () {
      for (final fileExtension in testImageExtensions) {
        expect(
            extractImageNameFromFileName('image.$fileExtension',
                imageFileExtension: fileExtension),
            'image');
      }
    });

    test('throws $ArgumentError when image file extension input is empty', () {
      expect(
        () => extractImageNameFromFileName('image.png', imageFileExtension: ''),
        throwsA(isA<ArgumentError>()
            .having((e) => e.message, 'message', equals('cannot be empty'))),
      );
    });
  });

  group('$SaveImageResult', () {
    test('overrides toString() correctly', () {
      const imageFilePath = '/path/to/file';
      const isGallerySave = false;
      expect(
        const SaveImageResult(
                imageFilePath: imageFilePath, isGallerySave: isGallerySave)
            .toString(),
        'SaveImageResult(imageFilePath: $imageFilePath, isGallerySave: $isGallerySave)',
      );
    });

    test('implements equality correctly', () {
      const imageFilePath = '/path/to/file.gif';
      const isGallerySave = true;

      expect(
        const SaveImageResult(
            imageFilePath: imageFilePath, isGallerySave: isGallerySave),
        const SaveImageResult(
            imageFilePath: imageFilePath, isGallerySave: isGallerySave),
        reason: 'two instances with the same values should be equal',
      );
    });

    test('overrides hashCode correctly', () {
      const imageFilePath = '/path/to/file.webp';
      const isGallerySave = false;
      expect(
        const SaveImageResult(
                imageFilePath: imageFilePath, isGallerySave: isGallerySave)
            .hashCode,
        const SaveImageResult(
                imageFilePath: imageFilePath, isGallerySave: isGallerySave)
            .hashCode,
      );
    });
  });

  test('defaultImageFileNamePrefix constant is correct', () {
    expect(defaultImageFileNamePrefix, equals('IMG'));
  });

  group('getDefaultImageFileName', () {
    if (kIsWeb) {
      test('returns default file name prefix when saving on the web', () {
        // The browser handles name conflicts.
        for (final isGallerySave in {true, false}) {
          expect(getDefaultImageFileName(isGallerySave: isGallerySave),
              defaultImageFileNamePrefix);
        }
      });
    }

    test('returns default file name prefix when saving to gallery', () {
      // The gallery app handles name conflicts.
      expect(getDefaultImageFileName(isGallerySave: true),
          defaultImageFileNamePrefix);
    });

    test(
        'returns default file name prefix for system save dialog on macOS and Windows',
        () {
      for (final platform in {TargetPlatform.macOS, TargetPlatform.windows}) {
        debugDefaultTargetPlatformOverride = platform;

        expect(getDefaultImageFileName(isGallerySave: false),
            defaultImageFileNamePrefix);
      }
    });

    test('returns unique file name for system save dialog image on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      final imageFileName = getDefaultImageFileName(isGallerySave: false);
      expect(imageFileName, isNot(equals(defaultImageFileNamePrefix)));

      final imageFileName2 = getDefaultImageFileName(isGallerySave: false);
      expect(
        imageFileName2,
        isNot(equals(imageFileName)),
        reason: 'File name should be unique',
      );

      final imageFileName3 = getDefaultImageFileName(isGallerySave: false);
      expect(
        imageFileName3,
        isNot(equals(imageFileName2)),
        reason: 'File name should be unique',
      );
      expect(
        imageFileName3,
        isNot(equals(imageFileName)),
        reason: 'File name should be unique',
      );
    });

    test('returns unique file name for other platforms', () {
      final imageFileName = getDefaultImageFileName(isGallerySave: false);
      expect(imageFileName, isNot(equals(defaultImageFileNamePrefix)));

      final imageFileName2 = getDefaultImageFileName(isGallerySave: false);
      expect(
        imageFileName2,
        isNot(equals(imageFileName)),
        reason: 'File name should be unique',
      );

      final imageFileName3 = getDefaultImageFileName(isGallerySave: false);
      expect(
        imageFileName3,
        isNot(equals(imageFileName2)),
        reason: 'File name should be unique',
      );
      expect(
        imageFileName3,
        isNot(equals(imageFileName)),
        reason: 'File name should be unique',
      );
    });
  });

  group('shouldSaveToGallery', () {
    late MockQuillNativeBridge mockQuillNativeBridge;

    void mockGallerySaveSupported(bool isSupported) =>
        when(() => mockQuillNativeBridge
                .isSupported(QuillNativeBridgeFeature.saveImageToGallery))
            .thenAnswer((_) async => isSupported);

    void mockImageSaveSupported(bool isSupported) =>
        when(() => mockQuillNativeBridge
                .isSupported(QuillNativeBridgeFeature.saveImage))
            .thenAnswer((_) async => isSupported);

    setUp(() {
      mockQuillNativeBridge = MockQuillNativeBridge();
      QuillNativeProvider.instance = mockQuillNativeBridge;
    });

    test(
        'returns false if gallery save not supported regardless of prefersGallerySave',
        () async {
      mockGallerySaveSupported(false);

      for (final prefersGallerySave in {true, false}) {
        final result =
            await shouldSaveToGallery(prefersGallerySave: prefersGallerySave);
        expect(result, isFalse);
        verify(() => mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.saveImageToGallery)).called(1);
        verifyNever(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage));
      }
    });

    test(
        'returns false when gallery save is not supported, regardless of if image save is supported',
        () async {
      mockGallerySaveSupported(false);

      for (final isImageSupported in {true, false}) {
        mockImageSaveSupported(isImageSupported);

        final result = await shouldSaveToGallery(prefersGallerySave: true);

        expect(result, isFalse);
        verify(() => mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.saveImageToGallery)).called(1);
        verifyNever(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage));
      }
    });

    test(
        'returns true if gallery save is supported and prefersGallerySave is true',
        () async {
      for (final imageSaveSupported in {true, false}) {
        mockGallerySaveSupported(true);
        mockImageSaveSupported(imageSaveSupported);

        final result = await shouldSaveToGallery(prefersGallerySave: true);

        expect(result, isTrue);
        verify(() => mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.saveImageToGallery)).called(1);
        verify(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage)).called(1);
      }
    });

    test(
        'returns true when gallery and image save are supported and prefersGallerySave is true',
        () async {
      mockGallerySaveSupported(true);
      mockImageSaveSupported(true);

      final result = await shouldSaveToGallery(prefersGallerySave: true);

      expect(result, isTrue);
      verify(() => mockQuillNativeBridge
          .isSupported(QuillNativeBridgeFeature.saveImageToGallery)).called(1);
      verify(() => mockQuillNativeBridge
          .isSupported(QuillNativeBridgeFeature.saveImage)).called(1);
    });

    test(
        'returns false when gallery and image save are supported and prefersGallerySave is false',
        () async {
      mockGallerySaveSupported(true);
      mockImageSaveSupported(true);

      final result = await shouldSaveToGallery(prefersGallerySave: false);

      expect(result, isFalse);
      verify(() => mockQuillNativeBridge
          .isSupported(QuillNativeBridgeFeature.saveImageToGallery)).called(1);
      verify(() => mockQuillNativeBridge
          .isSupported(QuillNativeBridgeFeature.saveImage)).called(1);
    });

    test(
        'returns false when gallery save is not supported and image save is supported regardless of prefersGallerySave',
        () async {
      mockGallerySaveSupported(false);
      mockImageSaveSupported(true);

      for (final prefersGallerySave in {true, false}) {
        final result =
            await shouldSaveToGallery(prefersGallerySave: prefersGallerySave);

        expect(result, isFalse);
        verify(() => mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.saveImageToGallery)).called(1);
        verifyNever(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage));
      }
    });

    test(
        'returns true when gallery save supported and image save not supported regardless of prefersGallerySave',
        () async {
      mockGallerySaveSupported(true);
      mockImageSaveSupported(false);

      for (final prefersGallerySave in {true, false}) {
        final result =
            await shouldSaveToGallery(prefersGallerySave: prefersGallerySave);

        expect(result, isTrue);
        verify(() => mockQuillNativeBridge.isSupported(
            QuillNativeBridgeFeature.saveImageToGallery)).called(1);
        verify(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage));
      }
    });
  });

  group('saveImage', () {
    late MockQuillNativeBridge mockQuillNativeBridge;
    late MockImageLoader mockImageLoader;
    late ImageSaver imageSaver;

    void mockGallerySaveSupported(bool isSupported) =>
        when(() => mockQuillNativeBridge
                .isSupported(QuillNativeBridgeFeature.saveImageToGallery))
            .thenAnswer((_) async => isSupported);

    void mockImageSaveSupported(bool isSupported) =>
        when(() => mockQuillNativeBridge
                .isSupported(QuillNativeBridgeFeature.saveImage))
            .thenAnswer((_) async => isSupported);

    Future<void> mockShouldSaveToGallery(bool shouldSaveToGalleryValue) async {
      if (shouldSaveToGalleryValue) {
        mockGallerySaveSupported(true);
        mockImageSaveSupported(false);
      } else {
        mockGallerySaveSupported(false);
        mockImageSaveSupported(true);
      }
      expect(
        await shouldSaveToGallery(prefersGallerySave: false),
        shouldSaveToGalleryValue,
        reason:
            'calling shouldSaveToGallery should return the value specified by mockShouldSaveToGallery',
      );
    }

    void mockLoadImageBytesValue(Uint8List? imageBytes) =>
        when(() => mockImageLoader.loadImageBytesFromImageProvider(
              imageProvider: any(named: 'imageProvider'),
            )).thenAnswer((_) async => imageBytes);

    setUp(() {
      mockQuillNativeBridge = MockQuillNativeBridge();
      QuillNativeProvider.instance = mockQuillNativeBridge;

      mockImageLoader = MockImageLoader();
      ImageLoader.instance = mockImageLoader;

      imageSaver = ImageSaver();

      mockGallerySaveSupported(false);
      mockImageSaveSupported(false);
      when(() =>
          mockQuillNativeBridge.saveImage(any(),
              options: any(named: 'options'))).thenAnswer(
          (_) async => const ImageSaveResult(blobUrl: null, filePath: null));

      when(() => mockQuillNativeBridge.saveImageToGallery(any(),
          options: any(named: 'options'))).thenAnswer((_) async {});
      mockLoadImageBytesValue(null);
    });

    setUpAll(() {
      registerFallbackValue(Uint8List.fromList([]));
      registerFallbackValue(
          const ImageSaveOptions(fileExtension: '', name: ''));
      registerFallbackValue(
        const GalleryImageSaveOptions(
            albumName: '', name: '', fileExtension: ''),
      );
      registerFallbackValue(FakeImageProvider());
    });

    test('throws $ArgumentError when image URL is empty', () async {
      await expectLater(
        imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '',
          prefersGallerySave: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('does not throw $ArgumentError when the image URL is not empty',
        () async {
      await imageSaver.saveImage(
        imageProvider: FakeImageProvider(),
        imageUrl: '/foo/bar',
        prefersGallerySave: false,
      );
      await expectLater(
        imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        ),
        completes,
      );
    });

    test('calls $ImageLoader to load the image bytes from the $ImageProvider',
        () async {
      await imageSaver.saveImage(
        imageUrl: 'imageUrl',
        imageProvider: FakeImageProvider(),
        prefersGallerySave: false,
      );
      verify(
        () => mockImageLoader.loadImageBytesFromImageProvider(
            imageProvider: any(named: 'imageProvider')),
      ).called(1);
    });

    test(
      'returns null when image bytes are null or empty',
      () async {
        await mockShouldSaveToGallery(true);

        for (final imageBytes in {Uint8List.fromList([]), null}) {
          mockLoadImageBytesValue(imageBytes);

          final result = await imageSaver.saveImage(
            imageProvider: FakeImageProvider(),
            imageUrl: '/foo/bar',
            prefersGallerySave: false,
          );
          expect(result, isNull);

          verify(
            () => mockImageLoader.loadImageBytesFromImageProvider(
                imageProvider: any(named: 'imageProvider')),
          ).called(1);
        }
      },
    );

    test(
      'calls saveImageToGallery from $QuillNativeBridge when shouldSaveToGallery is true',
      () async {
        await mockShouldSaveToGallery(true);

        mockLoadImageBytesValue(Uint8List.fromList([1, 0, 1]));
        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        );
        verify(
          () => mockQuillNativeBridge.saveImageToGallery(any(),
              options: any(named: 'options')),
        ).called(1);
      },
    );

    test(
      'does not call saveImageToGallery from $QuillNativeBridge when shouldSaveToGallery is false',
      () async {
        await mockShouldSaveToGallery(false);

        mockLoadImageBytesValue(Uint8List.fromList([1, 0, 1]));
        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        );
        verifyNever(
          () => mockQuillNativeBridge.saveImageToGallery(any(),
              options: any(named: 'options')),
        );
      },
    );

    test(
      'calls saveImageToGallery from $QuillNativeBridge when should save to the gallery and image bytes are not null',
      () async {
        await mockShouldSaveToGallery(true);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        final result = await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        );
        expect(
          result,
          const SaveImageResult(
            isGallerySave: true,
            imageFilePath: null,
          ),
        );
        verify(
          () => mockQuillNativeBridge.saveImageToGallery(any(),
              options: any(named: 'options')),
        ).called(1);
      },
    );

    test('returns null in case permission is denied', () async {
      await mockShouldSaveToGallery(true);

      mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

      when(() => mockQuillNativeBridge.saveImageToGallery(any(),
              options: any(named: 'options')))
          .thenThrow(PlatformException(code: 'PERMISSION_DENIED'));

      final result = await imageSaver.saveImage(
        imageProvider: FakeImageProvider(),
        imageUrl: '/foo/bar',
        prefersGallerySave: false,
      );
      expect(result, isNull);
    });

    test(
        'rethrows the $PlatformException in case permission is denied on macOS in debug-builds only (known macOS issue)',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await mockShouldSaveToGallery(true);

      mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

      final platformException = PlatformException(
          code: 'PERMISSION_DENIED', message: 'A known macOS issue');
      when(() => mockQuillNativeBridge.saveImageToGallery(any(),
          options: any(named: 'options'))).thenThrow(platformException);

      await expectLater(
        imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        ),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', platformException.code)
              .having((e) => e.message, 'message', platformException.message)
              .having((e) => e.details, 'details', platformException.details),
        ),
      );
    }, skip: kReleaseMode);

    test(
      'rethrows the $PlatformException from $QuillNativeBridge if not handled',
      () async {
        // Currently, that's the expected behavior but it is subject to changes for improvements.
        // See https://github.com/FlutterQuill/quill-native-bridge/issues/2

        await mockShouldSaveToGallery(true);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        final exception = PlatformException(
          code: 'EXAMPLE_CODE_${DateTime.now().toIso8601String()}',
          message: 'An example exception that is not handled',
        );
        when(() => mockQuillNativeBridge.saveImageToGallery(any(),
            options: any(named: 'options'))).thenThrow(exception);

        await expectLater(
          imageSaver.saveImage(
            imageProvider: FakeImageProvider(),
            imageUrl: '/foo/bar',
            prefersGallerySave: false,
          ),
          throwsA(equals(exception)),
        );
      },
    );

    test(
      'calls isSupported from $QuillNativeBridge to check if image save supported when gallery save skipped',
      () async {
        await mockShouldSaveToGallery(false);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        );

        verify(() => mockQuillNativeBridge
            .isSupported(QuillNativeBridgeFeature.saveImage)).called(1);
      },
    );

    test(
      'calls saveImage from $QuillNativeBridge when supported and should not use gallery save',
      () async {
        await mockShouldSaveToGallery(false);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        mockImageSaveSupported(true);

        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: '/foo/bar',
          prefersGallerySave: false,
        );

        verify(() => mockQuillNativeBridge.saveImage(any(),
            options: any(named: 'options'))).called(1);
      },
    );

    test(
      'does not calls saveImage from $QuillNativeBridge when unsupported and should not use gallery save',
      () async {
        await mockShouldSaveToGallery(false);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        mockImageSaveSupported(false);

        try {
          await imageSaver.saveImage(
            imageProvider: FakeImageProvider(),
            imageUrl: '/foo/bar',
            prefersGallerySave: false,
          );
        } on StateError catch (_) {
          // Skip since another test handles it
        }

        verifyNever(() => mockQuillNativeBridge.saveImage(any(),
            options: any(named: 'options')));
      },
    );

    test(
      'passes the arugments correctly to saveImageToGallery from $QuillNativeBridge',
      () async {
        await mockShouldSaveToGallery(true);

        final imageBytes = Uint8List.fromList([1, 0, 1]);
        mockLoadImageBytesValue(imageBytes);

        const imageUrl = 'path/to/file.png';
        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: imageUrl,
          prefersGallerySave: false,
        );

        final imageFileName = extractFileNameFromUrl(imageUrl);
        final imageFileExtension =
            extractImageFileExtensionFromFileName(imageFileName);
        final imageName = extractImageNameFromFileName(
          imageFileName,
          imageFileExtension: imageFileExtension,
        );

        verify(
          () => mockQuillNativeBridge.saveImageToGallery(
            imageBytes,
            options: GalleryImageSaveOptions(
              name: imageName ?? getDefaultImageFileName(isGallerySave: true),
              fileExtension: imageFileExtension,
              albumName: null,
            ),
          ),
        ).called(1);
      },
    );

    test(
      'passes the arugments correctly to saveImage from $QuillNativeBridge',
      () async {
        await mockShouldSaveToGallery(false);

        final imageBytes = Uint8List.fromList([1, 0, 1]);
        mockLoadImageBytesValue(imageBytes);

        mockImageSaveSupported(true);

        const imageUrl = 'path/to/file.png';
        await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: imageUrl,
          prefersGallerySave: false,
        );

        final imageFileName = extractFileNameFromUrl(imageUrl);
        final imageFileExtension =
            extractImageFileExtensionFromFileName(imageFileName);
        final imageName = extractImageNameFromFileName(
          imageFileName,
          imageFileExtension: imageFileExtension,
        );

        verify(
          () => mockQuillNativeBridge.saveImage(
            imageBytes,
            options: ImageSaveOptions(
              name: imageName ?? getDefaultImageFileName(isGallerySave: false),
              fileExtension: imageFileExtension,
            ),
          ),
        ).called(1);
      },
    );

    test(
      'returns the $SaveImageResult correctly for image save',
      () async {
        await mockShouldSaveToGallery(false);

        final imageBytes = Uint8List.fromList([1, 0, 1]);
        mockLoadImageBytesValue(imageBytes);

        mockImageSaveSupported(true);

        const inputImagePath = 'path/to/example_file.png';

        const savedImagePath = '/path/to/saved/example_file.png';

        when(
          () => mockQuillNativeBridge.saveImage(imageBytes,
              options: any(named: 'options')),
        ).thenAnswer((_) async =>
            const ImageSaveResult(filePath: savedImagePath, blobUrl: null));

        final result = await imageSaver.saveImage(
          imageProvider: FakeImageProvider(),
          imageUrl: inputImagePath,
          prefersGallerySave: false,
        );

        expect(
          result,
          const SaveImageResult(
              imageFilePath: savedImagePath, isGallerySave: false),
        );
      },
    );

    test(
      'throws $StateError when both image and gallery unsupported',
      () async {
        await mockShouldSaveToGallery(false);

        mockLoadImageBytesValue(Uint8List.fromList([1, 2, 2]));

        mockImageSaveSupported(false);

        await expectLater(
          imageSaver.saveImage(
            imageProvider: FakeImageProvider(),
            imageUrl: '/foo/bar',
            prefersGallerySave: false,
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message',
              'Image save is not handled on $defaultTargetPlatform')),
        );
      },
    );
  });
}

class MockQuillNativeBridge extends Mock implements QuillNativeBridge {}

class MockImageLoader extends Mock implements ImageLoader {}

class FakeImageProvider extends ImageProvider {
  @override
  Future<Object> obtainKey(ImageConfiguration configuration) async =>
      UnimplementedError('Fake implementation of $ImageProvider');
}
