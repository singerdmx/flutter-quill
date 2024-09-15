import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:quill_native_bridge/quill_native_bridge.dart';

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
            if (!{TargetPlatform.android, TargetPlatform.iOS}
                .contains(defaultTargetPlatform)) {
              scaffoldMessenger.showText(
                'Currently, this functionality is only supported on Android and iOS.',
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
