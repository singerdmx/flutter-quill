import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show DefaultStyles;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/youtube_video_support_mode.dart';
import '../youtube_video_url.dart';
import 'video_app.dart';

/// **Will be removed soon in future releases**.
@Deprecated(
  'Will be removed in future releases. See https://github.com/singerdmx/flutter-quill/issues/2284',
)
class YoutubeVideoApp extends StatefulWidget {
  const YoutubeVideoApp({
    required this.videoUrl,
    required this.readOnly,
    required this.youtubeVideoSupportMode,
    super.key,
  });

  final String videoUrl;
  final bool readOnly;
  final YoutubeVideoSupportMode youtubeVideoSupportMode;

  @override
  YoutubeVideoAppState createState() => YoutubeVideoAppState();
}

// ignore: deprecated_member_use_from_same_package
class YoutubeVideoAppState extends State<YoutubeVideoApp> {
  /// On some platforms such as desktop, Webview is not supported yet
  /// as a result the youtube video player package is not supported too
  /// this future will be not null and fetch the video url to load it using
  /// [VideoApp]
  Future<String>? _loadYoutubeVideoByDownloadUrlFuture;

  /// Null if the video URL is not a YouTube video
  String? get _videoId {
    // ignore: deprecated_member_use_from_same_package
    return convertVideoUrlToId(widget.videoUrl);
  }

  @override
  void initState() {
    super.initState();
    final videoId = _videoId;
    if (videoId == null) {
      return;
    }
    switch (widget.youtubeVideoSupportMode) {
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.disabled:
        break;
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.iframeView:
        assert(() {
          debugPrint(
            'Youtube Iframe is no longer supported on non-web platforms.\n'
            'See https://github.com/singerdmx/flutter-quill/issues/2284\n'
            'This message will only included in development mode.\n',
          );
          return true;
        }());
        break;
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.customPlayerWithDownloadUrl:
        _loadYoutubeVideoByDownloadUrlFuture =
            _loadYoutubeVideoWithVideoPlayerByVideoUrl();
        break;
    }
  }

  Future<String> _loadYoutubeVideoWithVideoPlayerByVideoUrl() async {
    final youtubeExplode = YoutubeExplode();
    final manifest =
        await youtubeExplode.videos.streamsClient.getManifest(_videoId);
    final streamInfo = manifest.muxed.withHighestBitrate();
    final videoDownloadUri = streamInfo.url;
    return videoDownloadUri.toString();
  }

  Widget _clickableVideoLinkText({required DefaultStyles defaultStyles}) {
    return RichText(
      text: TextSpan(
        text: widget.videoUrl,
        style: defaultStyles.link,
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrlString(widget.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint(
        "WARNING: It seems that you're using YoutubeVideoApp widget from flutter_quill_extensions "
        'which will be removed in future releases and will cause many issues.\n'
        'Use `customVideoBuilder` in the configuration class of `QuillEditorVideoEmbedConfigurations`.\n'
        'This message is only shown in development mode.\n'
        'Refer to https://github.com/singerdmx/flutter-quill/issues/2284 if you need help.',
      );
      return true;
    }());
    final defaultStyles = DefaultStyles.getInstance(context);

    switch (widget.youtubeVideoSupportMode) {
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.disabled:
        // Don't remove this assert, it's required to ensure
        // a smoother migration for users, will be only included in development mode
        assert(() {
          debugPrint(
            'Loading Youtube Videos has been disabled in recent versions of flutter_quill_extensions.\n'
            'See https://github.com/singerdmx/flutter-quill/issues/2284.\n'
            'We highly suggest to use the experimental property `QuillEditorVideoEmbedConfigurations.customVideoBuilder`\n'
            'in your configuration to handle YouTube video support.\n'
            'This message will only included in development mode.\n',
          );
          throw UnsupportedError(
            'Loading YouTube videos is no longer supported in flutter_quill_extensions.'
            'Take a look at the debug console for more details.\n'
            'Refer to https://github.com/singerdmx/flutter-quill/issues/2284 if you need help.\n'
            'This error will only happen in development mode, in production will return a clickable video link text.\n',
          );
        }());
        return _clickableVideoLinkText(defaultStyles: defaultStyles);
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.iframeView:
        if (widget.readOnly) {
          return _clickableVideoLinkText(defaultStyles: defaultStyles);
        }

        return RichText(
          text: TextSpan(text: widget.videoUrl, style: defaultStyles.link),
        );
      // ignore: deprecated_member_use_from_same_package
      case YoutubeVideoSupportMode.customPlayerWithDownloadUrl:
        assert(
          _loadYoutubeVideoByDownloadUrlFuture != null,
          'The load youtube video future should not null for "${widget.youtubeVideoSupportMode}" mode',
        );
        assert(() {
          debugPrint(
            'WARNING: Using the YouTube video download URL can violate their terms of service.\n'
            'This is already documented in customPlayerWithDownloadUrl option.\n'
            'See https://github.com/singerdmx/flutter-quill/issues/2284.\n'
            'We suggest to use the experimental property `QuillEditorVideoEmbedConfigurations.customVideoBuilder`\n'
            'in your configuration to handle YouTube video support.\n'
            'This message will only included in development mode.\n',
          );
          debugPrint(
            'WARNING: Using customPlayerWithDownloadUrl might not work anymore '
            'as YouTube servers can reject requests and respond with "Sign in to confirm you’re not a bot"\n'
            'See https://github.com/Hexer10/youtube_explode_dart/issues/282\n'
            'This message will only included in development mode.\n',
          );
          throw UnsupportedError(
            'Loading YouTube videos is no longer supported in flutter_quill_extensions.'
            'Take a look at the debug console for more details.\n'
            'Refer to https://github.com/singerdmx/flutter-quill/issues/2284 if you need help.\n'
            'This error will only happen in development mode, in producation, YouTube servers will respond with "Sign in to confirm you’re not a bot".\n',
          );
        }());

        return FutureBuilder<String>(
          future: _loadYoutubeVideoByDownloadUrlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return _clickableVideoLinkText(defaultStyles: defaultStyles);
            }
            return VideoApp(
              videoUrl: snapshot.requireData,
              readOnly: widget.readOnly,
            );
          },
        );
    }
  }
}
