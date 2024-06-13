import 'package:flutter/foundation.dart';

/// An abstraction to make it easy to provide different implementations
@immutable
abstract class ClipboardService {
  Future<bool> canProvideHtmlText();
  Future<String?> getHtmlText();

  Future<bool> canProvidePlainText();
  Future<String?> getPlainText();

  Future<bool> canProvideImageFile();
  Future<Uint8List> getImageFileAsBytes();

  Future<bool> canProvideGifFile();
  Future<Uint8List> getGifFileAsBytes();

  Future<bool> canPaste();
}
