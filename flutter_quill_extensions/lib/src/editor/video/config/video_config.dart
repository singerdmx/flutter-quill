import 'package:flutter/widgets.dart' show GlobalKey, Widget;
import 'package:meta/meta.dart' show experimental, immutable;

@immutable
class QuillEditorVideoEmbedConfig {
  const QuillEditorVideoEmbedConfig({
    this.onVideoInit,
    this.customVideoBuilder,
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

  /// [customVideoBuilder] is a callback function that receives the
  /// video URL and a read-only flag. This allows users to define
  /// their own logic for rendering video widgets, enabling support
  /// for various video platforms, such as YouTube.
  ///
  /// Example usage:
  /// ```dart
  ///   customVideoBuilder: (videoUrl, readOnly) {
  ///     // Return `null` to fallback to defualt logic of QuillEditorVideoEmbedBuilder
  ///
  ///     // Return a custom video widget based on the videoUrl
  ///     return CustomVideoWidget(videoUrl: videoUrl, readOnly: readOnly);
  ///   },
  /// ```
  ///
  /// It's a quick solution as response to https://github.com/singerdmx/flutter-quill/issues/2284
  ///
  /// **Might be removed or changed in future releases.**
  @experimental
  final Widget? Function(String videoUrl, bool readOnly)? customVideoBuilder;
}
