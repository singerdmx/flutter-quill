import 'package:meta/meta.dart';

/// **Will be removed soon in future releases**.
@experimental
@Deprecated(
  'YouTube video support will be removed soon and completely in the next releases.',
)
enum YoutubeVideoSupportMode {
  /// **Will be removed soon in future releases**.
  /// Disable loading of YouTube videos.
  /// **Will be removed soon in future releases**.
  @Deprecated('Loading YouTube videos is already disabled by default.')
  disabled,

  /// **Will be removed soon in future releases**.
  ///
  /// Load the video using the official YouTube IFrame API.
  /// See [YouTube IFrame API](https://developers.google.com/youtube/iframe_api_reference) for more details.
  ///
  /// This will use Platform View on native platforms to use WebView
  /// The WebView might not be supported on Desktop and will throw an exception
  ///
  /// See [Flutter InAppWebview Support for Flutter Desktop](https://github.com/pichillilorenzo/flutter_inappwebview/issues/460)
  ///
  /// **Important**: We had to remove [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
  /// and [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter)
  /// as non breaking change since most users are unable to build the project,
  /// preventing them from using
  ///
  /// **Will be removed soon in future releases**.
  @Deprecated(
    'This functionality has been removed to fix build failure issues. See https://github.com/singerdmx/flutter-quill/issues/2284 for discussion.',
  )
  iframeView,

  /// **Will be removed soon in future releases**.
  ///
  /// Load the video using a custom video player by fetching the YouTube video URL.
  /// Note: This might violate YouTube's terms of service.
  /// See [YouTube Terms of Service](https://www.youtube.com/static?template=terms) for more details.
  ///
  /// **WARNING**: We highly suggest to not use this solution,
  /// can cause issues with YouTube Terms of Service and require a extra dependency for all users.
  /// YouTube servers can reject requests and respond with `Sign in to confirm you’re not a bot`
  /// See related issue: https://github.com/Hexer10/youtube_explode_dart/issues/282
  ///
  /// **Will be removed soon in future releases**.
  @Deprecated(
    'Can cause issues with YouTube Terms of Service and require a extra dependency for all users - Will be removed soon.\n'
    'YouTube servers can reject requests and respond with "Sign in to confirm you’re not a bot"\n'
    'See related issue https://github.com/Hexer10/youtube_explode_dart/issues/282\n',
  )
  customPlayerWithDownloadUrl,
}
