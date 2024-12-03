import 'dart:async' show Completer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ImageLoader {
  static ImageLoader _instance = ImageLoader();

  static ImageLoader get instance => _instance;

  /// Allows overriding the instance for testing
  @visibleForTesting
  static set instance(ImageLoader newInstance) => _instance = newInstance;

  // TODO(performance): This will load the image again. In case
//  this is a network image, then this will be inefficient.
  Future<Uint8List?> loadImageBytesFromImageProvider({
    required ImageProvider imageProvider,
  }) async {
    final stream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();

    ImageStreamListener? listener;
    listener = ImageStreamListener((info, _) {
      completer.complete(info.image);
      stream.removeListener(listener!);
    });

    stream.addListener(listener);

    final image = await completer.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
