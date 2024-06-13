import 'dart:io' show File;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../flutter_quill_extensions.dart';

/// Widget for playing back video
/// Refer to https://github.com/flutter/plugins/tree/master/packages/video_player/video_player
class VideoApp extends StatefulWidget {
  const VideoApp({
    required this.videoUrl,
    required this.readOnly,
    @Deprecated(
      'The context is no longer required and will be removed on future releases',
    )
    BuildContext? context,
    super.key,
    this.onVideoInit,
  });

  final String videoUrl;
  final bool readOnly;
  final void Function(GlobalKey videoContainerKey)? onVideoInit;

  @override
  VideoAppState createState() => VideoAppState();
}

class VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  GlobalKey videoContainerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _controller = isHttpBasedUrl(widget.videoUrl)
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.file(File(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
        if (widget.onVideoInit != null) {
          widget.onVideoInit?.call(videoContainerKey);
        }
      }).catchError((error) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyles = DefaultStyles.getInstance(context);
    if (_controller.value.hasError) {
      if (widget.readOnly) {
        return RichText(
          text: TextSpan(
            text: widget.videoUrl,
            style: defaultStyles.link,
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(
                    Uri.parse(widget.videoUrl),
                  ),
          ),
        );
      }

      return RichText(
        text: TextSpan(
          text: widget.videoUrl,
          style: defaultStyles.link,
        ),
      );
    } else if (!_controller.value.isInitialized) {
      return VideoProgressIndicator(
        _controller,
        allowScrubbing: true,
        colors: const VideoProgressColors(playedColor: Colors.blue),
      );
    }

    return Container(
      key: videoContainerKey,
      child: InkWell(
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
                child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )),
            _controller.value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    color: const Color(0xfff5f5f5),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 60,
                      color: Colors.blueGrey,
                    ),
                  )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
