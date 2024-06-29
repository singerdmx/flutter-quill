/// Enum represents the different modes for handling YouTube video support.
enum YoutubeVideoSupportMode {
  /// Disable loading of YouTube videos.
  disabled,

  /// Load the video using the official YouTube IFrame API.
  /// See [YouTube IFrame API](https://developers.google.com/youtube/iframe_api_reference) for more details.
  ///
  /// This will use Platform View on native platforms to use WebView
  /// The WebView might not be supported on Desktop and will throw an exception
  ///
  /// See [Flutter InAppWebview Support for Flutter Desktop](https://github.com/pichillilorenzo/flutter_inappwebview/issues/460)
  iframeView,

  /// Load the video using a custom video player by fetching the YouTube video URL.
  /// Note: This might violate YouTube's terms of service.
  /// See [YouTube Terms of Service](https://www.youtube.com/static?template=terms) for more details.
  customPlayerWithDownloadUrl,
}
