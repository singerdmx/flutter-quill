import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:quill_native_bridge/quill_native_bridge.dart';

void main() {
  runApp(const MyApp());
}

const _flutterQuillAssetImage = 'assets/flutter-quill.png';

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
          _flutterQuillAssetImage,
          width: 300,
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            if (kIsWeb) {
              scaffoldMessenger.showText(
                "Can't check if the device is simulator on web.",
              );
              return;
            }
            if (defaultTargetPlatform != TargetPlatform.iOS) {
              scaffoldMessenger.showText(
                'Must be on iOS to check if simualtor.',
              );
              return;
            }
            final result = await QuillNativeBridge.isIOSSimulator();
            scaffoldMessenger.showText(result
                ? "You're running the app on iOS simulator"
                : "You're running the app on real iOS device.");
          },
          child: const Text('Is iOS Simulator'),
        ),
        ElevatedButton(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            if (kIsWeb) {
              scaffoldMessenger.showText(
                "Can't get the HTML content from Clipboard on web without paste event on web.",
              );
              return;
            }
            if (!QuillNativeBridge.isClipboardOperationsSupported) {
              scaffoldMessenger.showText(
                'Currently, this functionality is only supported on Android, iOS and macOS.',
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
          },
          child: const Text('Get HTML from Clipboard'),
        ),
        ElevatedButton(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            if (!QuillNativeBridge.isClipboardOperationsSupported) {
              scaffoldMessenger.showText(
                'Currently, this functionality is only supported on Android, iOS, macOS and Web.',
              );
              return;
            }
            final imageBytes = (await rootBundle.load(_flutterQuillAssetImage))
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
          },
          child: const Text('Copy Image to Clipboard'),
        ),
        ElevatedButton(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            // TODO: Update this check if web supported or not
            if (kIsWeb) {
              scaffoldMessenger.showText(
                'Retrieving image from the clipboard is currently not supported.',
              );
              return;
            }
            if (!QuillNativeBridge.isClipboardOperationsSupported) {
              scaffoldMessenger.showText(
                'Currently, this functionality is only supported on Android, iOS, and macOS.',
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
          },
          child: const Text('Retrive Image from Clipboard'),
        ),
      ],
    );
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
