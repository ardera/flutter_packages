// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to extract code samples for the README.md file.
// Run update-excerpts if you modify this file.

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutterpi_gstreamer_video_player/flutterpi_gstreamer_video_player.dart';

void main() {
  FlutterpiVideoPlayer.registerWith();
  runApp(const _VideoApp());
}

class ExampleVideoPage extends StatefulWidget {
  const ExampleVideoPage({super.key});

  @override
  State<ExampleVideoPage> createState() => _ExampleVideoPageState();
}

class _ExampleVideoPageState extends State<ExampleVideoPage> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    );

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      additionalOptions: (context) {
        return [
          OptionItem(
            onTap: () {
              _controller.stepForward();
            },
            iconData: Icons.arrow_right,
            title: 'Step Forward',
          ),
          OptionItem(
            onTap: () {
              _controller.stepBackward();
            },
            iconData: Icons.arrow_left,
            title: 'Step Backward',
          ),
          OptionItem(
            onTap: () {},
            iconData: Icons.fast_forward_outlined,
            title: 'Fast Seek',
          ),
        ];
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({super.key});

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _controller = FlutterpiVideoPlayerController.withGstreamerPipeline(
      'libcamerasrc ! queue ! appsink name="sink"',
    );

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      isLive: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}

class _VideoApp extends StatefulWidget {
  const _VideoApp({Key? key}) : super(key: key);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<_VideoApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Example Video'),
                Tab(text: 'Camera'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ExampleVideoPage(),
              CameraViewPage(),
            ],
          ),
        ),
      ),
    );
  }
}
