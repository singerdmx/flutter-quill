import 'dart:async' show Completer;
import 'dart:convert' show utf8;

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill_internal.dart'
    show ClipboardService;
import 'package:meta/meta.dart' show experimental;

import 'package:super_clipboard/super_clipboard.dart';

/// Implementation using the https://pub.dev/packages/super_clipboard plugin.
@experimental
class SuperClipboardService extends ClipboardService {
  /// [Null] if the Clipboard API is not supported on this platform
  /// https://pub.dev/packages/super_clipboard#usage
  SystemClipboard? _getSuperClipboard() {
    return SystemClipboard.instance;
  }

  SystemClipboard _getSuperClipboardOrThrow() {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      // To avoid getting this exception, use _canProvide()
      throw UnsupportedError(
        'Clipboard API is not supported on this platform.',
      );
    }
    return clipboard;
  }

  Future<bool> _canProvide({required DataFormat format}) async {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      return false;
    }
    final reader = await clipboard.read();
    return reader.canProvide(format);
  }

  Future<Uint8List> _provideFileAsBytes({
    required SimpleFileFormat format,
  }) async {
    final clipboard = _getSuperClipboardOrThrow();
    final reader = await clipboard.read();
    final completer = Completer<Uint8List>();

    reader.getFile(
      format,
      (file) async {
        final bytes = await file.readAll();
        completer.complete(bytes);
      },
      onError: completer.completeError,
    );
    final bytes = await completer.future;
    return bytes;
  }

  Future<String> _provideFileAsString({
    required SimpleFileFormat format,
  }) async {
    final fileBytes = await _provideFileAsBytes(format: format);
    final fileText = utf8.decode(fileBytes);
    return fileText;
  }

  /// According to super_clipboard docs, will return `null` if the value
  /// is not available or the data is virtual (macOS and Windows)
  Future<String?> _provideSimpleValueFormatAsString({
    required SimpleValueFormat<String> format,
  }) async {
    final clipboard = _getSuperClipboardOrThrow();
    final reader = await clipboard.read();
    final value = await reader.readValue<String>(format);
    return value;
  }

  @override
  Future<String?> getHtmlText() async {
    if (!(await _canProvide(format: Formats.htmlText))) {
      return null;
    }
    return _provideSimpleValueFormatAsString(format: Formats.htmlText);
  }

  @override
  Future<String?> getHtmlFile() async {
    if (!(await _canProvide(format: Formats.htmlFile))) {
      return null;
    }
    return await _provideFileAsString(format: Formats.htmlFile);
  }

  @override
  Future<Uint8List?> getGifFile() async {
    if (!(await _canProvide(format: Formats.gif))) {
      return null;
    }
    return await _provideFileAsBytes(format: Formats.gif);
  }

  @override
  Future<Uint8List?> getImageFile() async {
    final canProvidePngFile = await _canProvide(format: Formats.png);
    if (canProvidePngFile) {
      return _provideFileAsBytes(format: Formats.png);
    }
    final canProvideJpegFile = await _canProvide(format: Formats.jpeg);
    if (canProvideJpegFile) {
      return _provideFileAsBytes(format: Formats.jpeg);
    }
    return null;
  }

  @override
  Future<String?> getMarkdownFile() async {
    // Formats.md is for markdown files
    if (!(await _canProvide(format: Formats.md))) {
      return null;
    }
    return await _provideFileAsString(format: Formats.md);
  }

  @override
  Future<void> copyImage(Uint8List imageBytes) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      return;
    }
    final item = DataWriterItem()..add(Formats.png(imageBytes));
    await clipboard.write([item]);
  }

  @override
  Future<bool> get hasClipboardContent async {
    final clipboard = _getSuperClipboard();
    if (clipboard == null) {
      return false;
    }
    final reader = await clipboard.read();
    final availablePlatformFormats = reader.platformFormats;
    return availablePlatformFormats.isNotEmpty;
  }
}
