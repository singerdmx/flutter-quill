import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:quill_native_bridge/quill_native_bridge.dart'
    show QuillNativeBridge, QuillNativeBridgeFeature;

import 'assets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Quill Native Bridge'),
        ),
        body: const Center(
          child: Buttons(),
        ),
      ),
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          kFlutterQuillAssetImage,
          width: 300,
        ),
        const SizedBox(height: 50),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.isIOSSimulator,
            context: context,
          ),
          label: const Text('Is iOS Simulator'),
          icon: const Icon(Icons.apple),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.getClipboardHtml,
            context: context,
          ),
          label: const Text('Get HTML from Clipboard'),
          icon: const Icon(Icons.html),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.copyHtmlToClipboard,
            context: context,
          ),
          label: const Text('Copy HTML to Clipboard'),
          icon: const Icon(Icons.copy),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.copyImageToClipboard,
            context: context,
          ),
          label: const Text('Copy Image to Clipboard'),
          icon: const Icon(Icons.copy),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.getClipboardImage,
            context: context,
          ),
          label: const Text('Retrieve Image from Clipboard'),
          icon: const Icon(Icons.image),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.getClipboardGif,
            context: context,
          ),
          label: const Text('Retrieve Gif from Clipboard'),
          icon: const Icon(Icons.gif),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgeFeature.getClipboardFiles,
            context: context,
          ),
          label: const Text('Retrieve Files from Clipboard'),
          icon: const Icon(Icons.file_open),
        ),
      ],
    );
  }

  Future<void> _onButtonClick(
    QuillNativeBridgeFeature feature, {
    required BuildContext context,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final isFeatureUnsupported =
        !(await QuillNativeBridge.isSupported(feature));
    final isFeatureWebUnsupported = isFeatureUnsupported && kIsWeb;
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? "Can't check if the device is iOS simulator on the web."
                : 'Must be on iOS to check if simualtor.',
          );
          return;
        }
        final result = await QuillNativeBridge.isIOSSimulator();
        scaffoldMessenger.showText(result
            ? "You're running the app on iOS simulator"
            : "You're running the app on real iOS device.");
        break;
      case QuillNativeBridgeFeature.getClipboardHtml:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retrieving HTML from the Clipboard is currently not supported on the web.'
                : 'Getting HTML from the Clipboard is not supported on ${defaultTargetPlatform.name}',
          );
          return;
        }
        final result = await QuillNativeBridge.getClipboardHtml();
        if (result == null) {
          scaffoldMessenger.showText(
            'The HTML is not available on the clipboard.',
          );
          return;
        }
        scaffoldMessenger.showText(
          'HTML from the clipboard: $result',
        );
        debugPrint('HTML from the clipboard: $result');
        break;
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Copying HTML to the Clipboard is currently not supported on the web.'
                : 'Copying HTML to the Clipboard is not supported on ${defaultTargetPlatform.name}',
          );
          return;
        }
        const html = '''
          <strong>Bold text</strong>
          <em>Italic text</em>
          <u>Underlined text</u>
          <span style="color:red;">Red text</span>
          <span style="background-color:yellow;">Highlighted text</span>
        ''';
        await QuillNativeBridge.copyHtmlToClipboard(html);
        scaffoldMessenger.showText(
          'HTML copied to the clipboard: $html',
        );
        break;
      case QuillNativeBridgeFeature.copyImageToClipboard:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Copying an image to the clipboard is currently not supported on web.'
                : 'Copying an image to the Clipboard is not supported on ${defaultTargetPlatform.name}',
          );
          return;
        }
        final imageBytes = await loadAssetFile(kFlutterQuillAssetImage);
        await QuillNativeBridge.copyImageToClipboard(imageBytes);

        // Not widely supported but some apps copy the image as a text:
        // final file = File(
        //   '${Directory.systemTemp.path}/clipboard-image.png',
        // );
        // await file.create(recursive: true);
        // await file.writeAsBytes(imageBytes);
        // Clipboard.setData(
        //   ClipboardData(
        //     // Currently the Android plugin doesn't support content://
        //     text: 'file://${file.absolute.path}',
        //   ),
        // );

        scaffoldMessenger.showText(
          'Image has been copied to the clipboard.',
        );
        break;
      case QuillNativeBridgeFeature.getClipboardImage:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retrieving an image from the clipboard is currently not supported on web.'
                : 'Retrieving an image from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final imageBytes = await QuillNativeBridge.getClipboardImage();
        if (imageBytes == null) {
          scaffoldMessenger.showText(
            'The image is not available on the clipboard.',
          );
          return;
        }
        if (!context.mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Image.memory(imageBytes),
          ),
        );
        break;
      case QuillNativeBridgeFeature.getClipboardGif:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retrieving a gif from the clipboard is currently not supported on web.'
                : 'Retrieving a gif from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final gifBytes = await QuillNativeBridge.getClipboardGif();
        if (gifBytes == null) {
          scaffoldMessenger.showText(
            'The gif is not available on the clipboard.',
          );
          return;
        }
        if (!context.mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Image.memory(gifBytes),
          ),
        );
        break;
      case QuillNativeBridgeFeature.getClipboardFiles:
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retrieving files from the clipboard is currently not supported on web.'
                : 'Retrieving files from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
          );
          return;
        }
        final files = await QuillNativeBridge.getClipboardFiles();
        if (files.isEmpty) {
          scaffoldMessenger.showText('There are no files on the clipboard.');
          return;
        }
        scaffoldMessenger.showText(
          '${files.length} Files from the clipboard: ${files.toString()}',
        );
        debugPrint('Files from the clipboard: $files');
        break;
    }
  }
}

extension ScaffoldMessengerX on ScaffoldMessengerState {
  void showText(String text) {
    clearSnackBars();
    showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }
}
