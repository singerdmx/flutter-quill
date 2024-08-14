import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show DefaultStyles;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/youtube_video_support_mode.dart';
import 'video_app.dart';

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

class YoutubeVideoAppState extends State<YoutubeVideoApp> {
  YoutubePlayerController? _youtubeIframeController;

  /// On some platforms such as desktop, Webview is not supported yet
  /// as a result the youtube video player package is not supported too
  /// this future will be not null and fetch the video url to load it using
  /// [VideoApp]
  Future<String>? _loadYoutubeVideoByDownloadUrlFuture;

  /// Null if the video URL is not a YouTube video
  String? get _videoId {
    return YoutubePlayer.convertUrlToId(widget.videoUrl);
  }

  @override
  void initState() {
    super.initState();
    final videoId = _videoId;
    if (videoId == null) {
      return;
    }
    switch (widget.youtubeVideoSupportMode) {
      case YoutubeVideoSupportMode.disabled:
        break;
      case YoutubeVideoSupportMode.iframeView:
        _youtubeIframeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
          ),
        );
        break;
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
    final defaultStyles = DefaultStyles.getInstance(context);

    switch (widget.youtubeVideoSupportMode) {
      case YoutubeVideoSupportMode.disabled:
        throw UnsupportedError('YouTube video links are not supported');
      case YoutubeVideoSupportMode.iframeView:
        final youtubeController = _youtubeIframeController;

        if (youtubeController == null) {
          if (widget.readOnly) {
            return _clickableVideoLinkText(defaultStyles: defaultStyles);
          }

          return RichText(
            text: TextSpan(text: widget.videoUrl, style: defaultStyles.link),
          );
        }
        return YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: youtubeController,
            showVideoProgressIndicator: true,
          ),
          builder: (context, player) {
            return player;
          },
        );
      case YoutubeVideoSupportMode.customPlayerWithDownloadUrl:
        assert(
          _loadYoutubeVideoByDownloadUrlFuture != null,
          'The load youtube video future should not null for "${widget.youtubeVideoSupportMode}" mode',
        );

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

  @override
  void dispose() {
    _youtubeIframeController?.dispose();
    super.dispose();
  }
}
