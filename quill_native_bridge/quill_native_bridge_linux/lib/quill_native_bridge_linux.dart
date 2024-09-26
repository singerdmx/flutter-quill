// This file is referenced by pubspec.yaml. If you plan on moving this file
// Make sure to update pubspec.yaml to the new location.

import 'dart:convert' show utf8;
import 'dart:io' show Process, File hide exitCode;

import 'package:flutter/services.dart' show Uint8List;
import 'package:quill_native_bridge_platform_interface/quill_native_bridge_platform_interface.dart';

import 'src/binary_runner.dart';
import 'src/constants.dart';
import 'src/mime_types_constants.dart';
import 'src/temp_file_utils.dart';

/// A Linux implementation of the [QuillNativeBridgePlatform].
///
/// **Highly Experimental** and can be removed.
///
/// Should extends [QuillNativeBridgePlatform] and not implements it as error will arise:
///
/// ```console
/// Assertion failed: "Platform interfaces must not be implemented with `implements`"
/// ```
///
/// See [Flutter #127396](https://github.com/flutter/flutter/issues/127396)
/// and [QuillNativeBridgePlatform] for more details.
/// ```
class QuillNativeBridgeLinux extends QuillNativeBridgePlatform {
  QuillNativeBridgeLinux._();

  static void registerWith() {
    QuillNativeBridgePlatform.instance = QuillNativeBridgeLinux._();
  }

  @override
  Future<bool> isSupported(QuillNativeBridgeFeature feature) async {
    switch (feature) {
      case QuillNativeBridgeFeature.isIOSSimulator:
        return false;
      case QuillNativeBridgeFeature.getClipboardHtml:
      case QuillNativeBridgeFeature.copyHtmlToClipboard:
      case QuillNativeBridgeFeature.copyImageToClipboard:
      case QuillNativeBridgeFeature.getClipboardImage:
        return true;
      case QuillNativeBridgeFeature.getClipboardGif:
        return false;
      // Without this default check, adding new item to the enum will be a breaking change
      default:
        throw UnimplementedError(
          'Checking if `${feature.name}` is supported on Linux is not covered.',
        );
    }
  }

  // TODO: Improve error handling

  // TODO: The xclipFile should always be removed in finally block, extractBinaryFromAsset()
  //  should be part of the try-catch

  // TODO: Support wayland https://github.com/bugaevc/wl-clipboard.
  //  Need to abstract implementation of xclip first.

  // TODO: Might want to improve the description of _hasClipboardItemOfType()

  /// Check if the system clipboard has [mimeType] to paste using [xclip](https://github.com/astrand/xclip).
  ///
  /// `xclip` doesn't throw an error when retrieving a clipboard item
  /// while specifying type using `-t text/html`.
  ///
  /// Without this check, will return the last copied
  /// item even if the last item is an image (as bytes).
  ///
  /// This only check the type in the clipboard selection.
  Future<bool> _hasClipboardItemOfType({
    required String mimeType,
    required String xclipFilePath,
  }) async {
    return (await Process.run(
            xclipFilePath, ['-selection', 'clipboard', '-t', 'TARGETS', '-o']))
        .stdout
        .toString()
        .contains(mimeType);
  }

  @override
  Future<String?> getClipboardHtml() async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      // TODO: Write a test case where copying an image and then retrieving HTML
      //  should not throw an exception or unexpected behavior. Not required
      //  since some of the tests will fail if this issue happen.

      // TODO: Should check if the expected type is avalaible before
      //  avaliable before getting it using: xclip -o -t TARGETS
      final hasHtmlInClipboard = await _hasClipboardItemOfType(
        mimeType: kHtmlMimeType,
        xclipFilePath: xclipFile.path,
      );
      if (!hasHtmlInClipboard) {
        return null;
      }
      final result = await Process.run(
        xclipFile.path,
        ['-selection', 'clipboard', '-o', '-t', kHtmlMimeType],
      );
      if (result.exitCode == 0) {
        return (result.stdout as String?)?.trim();
      }
      final processErrorOutput = result.stderr.toString().trim();
      if (processErrorOutput
          .startsWith('Error: target $kHtmlMimeType not available')) {
        return null;
      }
      assert(
        false,
        'Error retrieving the HTML to clipboard. Exit code: ${result.exitCode}\nError output: $processErrorOutput',
      );
    } finally {
      await xclipFile.delete();
    }
    return null;
  }

  @override
  Future<void> copyHtmlToClipboard(String html) async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);

    try {
      final process = await Process.start(
        xclipFile.path,
        [
          '-selection',
          'clipboard',
          '-t',
          kHtmlMimeType,
        ],
      );
      process.stdin.writeln(html);
      await process.stdin.close();
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final processErrorOutput =
            await process.stderr.transform(utf8.decoder).join();
        assert(
          false,
          'Error copying the HTML to clipboard. Exit code: $exitCode\nError output: $processErrorOutput',
        );
      }
    } finally {
      await xclipFile.delete();
    }
  }

  @override
  Future<void> copyImageToClipboard(Uint8List imageBytes) async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    final tempClipboardImageFileName =
        'tempClipboardImage-${DateTime.now().millisecondsSinceEpoch}.png';
    final tempClipboardImage =
        File(generateTempFilePath(tempClipboardImageFileName));

    try {
      await tempClipboardImage.writeAsBytes(imageBytes);

      final process = await Process.start(
        xclipFile.path,
        [
          '-selection',
          'clipboard',
          '-t',
          kImagePngMimeType,
          '-i',
          tempClipboardImage.path,
        ],
      );
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final errorOutput = await process.stderr.transform(utf8.decoder).join();
        assert(
          false,
          'Error copying the image to clipboard. Exit code: $exitCode\nError output: $errorOutput',
        );
      }
    } finally {
      await xclipFile.delete();
      await tempClipboardImage.delete();
    }
  }

  @override
  Future<Uint8List?> getClipboardImage() async {
    final xclipFile = await extractBinaryFromAsset(kXclipAssetFile);
    try {
      final hasImagePngInClipboard = await _hasClipboardItemOfType(
        mimeType: kImagePngMimeType,
        xclipFilePath: xclipFile.path,
      );
      if (!hasImagePngInClipboard) {
        return null;
      }
      final result = await Process.run(
        xclipFile.path,
        ['-selection', 'clipboard', '-t', kImagePngMimeType, '-o'],
        // Set stdoutEncoding to null. Expecting raw bytes.
        stdoutEncoding: null,
      );
      if (result.exitCode == 0) {
        return result.stdout as Uint8List?;
      }
      final processErrorOutput = result.stderr.toString().trim();
      if (processErrorOutput
          .startsWith('Error: target $kImagePngMimeType not available')) {
        return null;
      }
      assert(
        false,
        'Unknown error while retrieving image from the clipboard. Exit code: ${result.exitCode}. Error output $processErrorOutput',
      );
    } finally {
      await xclipFile.delete();
    }
    return null;
  }
}
