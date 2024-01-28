import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:meta/meta.dart' show immutable;

@immutable
class QuillEditorVideoEmbedConfigurations {
  const QuillEditorVideoEmbedConfigurations({
    this.onVideoInit,
  });

  /// [onVideoInit] is a callback function that gets triggered when
  ///  a video is initialized.
  /// You can use this to perform actions or setup configurations related
  ///  to video embedding.
  ///
  ///
  /// Example usage:
  /// ```dart
  ///   onVideoInit: (videoContainerKey) {
  ///     // Custom video initialization logic
  ///   },
  ///   // Customize other callback functions as needed
  /// ```
  final void Function(GlobalKey videoContainerKey)? onVideoInit;
}
