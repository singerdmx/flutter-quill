import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart' show DefaultStyles;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_app.dart';

class YoutubeVideoApp extends StatefulWidget {
  const YoutubeVideoApp({
    required this.videoUrl,
    required this.readOnly,
    super.key,
  });

  final String videoUrl;
  final bool readOnly;

  @override
  YoutubeVideoAppState createState() => YoutubeVideoAppState();
}

class YoutubeVideoAppState extends State<YoutubeVideoApp> {
  YoutubePlayerController? _youtubeController;
  late String? _videoId;

  /// On some platforms such as desktop, Webview is not supported yet
  /// as a result the youtube video player package is not supported too
  /// this future will be not null and fetch the video url to load it using
  /// [VideoApp]
  Future<String>? _loadYoutubeVideoWithVideoPlayer;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    final videoId = _videoId;
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ),
      );
      if (isDesktop(supportWeb: false)) {
        _loadYoutubeVideoWithVideoPlayer =
            _loadYoutubeVideoWithVideoPlayerByVideoUrl();
      }
    }
  }

  Future<String> _loadYoutubeVideoWithVideoPlayerByVideoUrl() async {
    final youtubeExplode = YoutubeExplode();
    final manifest =
        await youtubeExplode.videos.streamsClient.getManifest(_videoId);
    final streamInfo = manifest.muxed.withHighestBitrate();
    final downloadUrl = streamInfo.url;
    return downloadUrl.toString();
  }

  Widget _videoLink({required DefaultStyles defaultStyles}) {
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
    final youtubeController = _youtubeController;

    if (youtubeController == null) {
      if (widget.readOnly) {
        return _videoLink(defaultStyles: defaultStyles);
      }

      return RichText(
        text: TextSpan(text: widget.videoUrl, style: defaultStyles.link),
      );
    }

    // Workaround as YoutubePlayer doesn't support Desktop
    if (_loadYoutubeVideoWithVideoPlayer != null) {
      return FutureBuilder<String>(
        future: _loadYoutubeVideoWithVideoPlayer,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return _videoLink(defaultStyles: defaultStyles);
          }
          return VideoApp(
            videoUrl: snapshot.requireData,
            readOnly: widget.readOnly,
          );
        },
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
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }
}
