import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:quill_native_bridge/quill_native_bridge.dart'
    show QuillNativeBridge, QuillNativeBridgePlatformFeature;

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
            QuillNativeBridgePlatformFeature.isIOSSimulator,
            context: context,
          ),
          label: const Text('Is iOS Simulator'),
          icon: const Icon(Icons.apple),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgePlatformFeature.getClipboardHTML,
            context: context,
          ),
          label: const Text('Get HTML from Clipboard'),
          icon: const Icon(Icons.html),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgePlatformFeature.copyImageToClipboard,
            context: context,
          ),
          label: const Text('Copy Image to Clipboard'),
          icon: const Icon(Icons.copy),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgePlatformFeature.getClipboardImage,
            context: context,
          ),
          label: const Text('Retrieve Image from Clipboard'),
          icon: const Icon(Icons.image),
        ),
        ElevatedButton.icon(
          onPressed: () => _onButtonClick(
            QuillNativeBridgePlatformFeature.getClipboardGif,
            context: context,
          ),
          label: const Text('Retrieve Gif from Clipboard'),
          icon: const Icon(Icons.gif),
        ),
      ],
    );
  }

  Future<void> _onButtonClick(
    QuillNativeBridgePlatformFeature platformFeature, {
    required BuildContext context,
  }) async {
    final isFeatureUnsupported = platformFeature.isUnsupported;
    final isFeatureWebUnsupported = !platformFeature.hasWebSupport && kIsWeb;
    switch (platformFeature) {
      case QuillNativeBridgePlatformFeature.isIOSSimulator:
        final scaffoldMessenger = ScaffoldMessenger.of(context);
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
      case QuillNativeBridgePlatformFeature.getClipboardHTML:
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retriving HTML from the Clipboard is currently not supported on the web.'
                : 'Getting HTML from the Clipboard is not supported on ${defaultTargetPlatform.name}',
          );
          return;
        }
        final result = await QuillNativeBridge.getClipboardHTML();
        if (result == null) {
          scaffoldMessenger.showText(
            'The HTML is not available on the clipboard.',
          );
          return;
        }
        scaffoldMessenger.showText(
          'HTML copied to clipboard: $result',
        );
        await Clipboard.setData(ClipboardData(text: result));
        debugPrint('HTML from the clipboard: $result');
        break;
      case QuillNativeBridgePlatformFeature.copyImageToClipboard:
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Copying an image to the clipboard is currently not supported on web.'
                : 'Copying an image to the Clipboard is not supported on ${defaultTargetPlatform.name}',
          );
          return;
        }
        final imageBytes = (await rootBundle.load(kFlutterQuillAssetImage))
            .buffer
            .asUint8List();
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
      case QuillNativeBridgePlatformFeature.getClipboardImage:
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retriving an image from the clipboard is currently not supported on web.'
                : 'Retriving an image from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
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
      case QuillNativeBridgePlatformFeature.getClipboardGif:
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (isFeatureUnsupported) {
          scaffoldMessenger.showText(
            isFeatureWebUnsupported
                ? 'Retriving a gif from the clipboard is currently not supported on web.'
                : 'Retriving a gif from the clipboard is currently not supported on ${defaultTargetPlatform.name}.',
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
