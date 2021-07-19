import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget for playing back video
/// Refer to https://github.com/flutter/plugins/tree/master/packages/video_player/video_player
class VideoApp extends StatefulWidget {
  const VideoApp({required this.videoUrl});
  final String videoUrl;

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.videoUrl.startsWith('http')
        ? VideoPlayerController.network(widget.videoUrl)
        : VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: InkWell(
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Stack(alignment: Alignment.center, children: [
          Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator()),
          _controller.value.isPlaying || !_controller.value.isInitialized
              ? const SizedBox.shrink()
              : Container(
                  color: const Color(0x00fafafa),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 60,
                    color: Colors.blueGrey,
                  ))
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
