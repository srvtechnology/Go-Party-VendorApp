import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utsavlife/core/utils/logger.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  String url;
  VideoApp({super.key,required this.url});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  @override
  void initState() {

    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    _controller = VideoPlayerController.network(
        widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
    CustomLogger.debug(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    _controller.dispose();
  }
}