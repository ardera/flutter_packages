import 'package:flutterpi_gstreamer_video_player/src/platform.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void _checkPlatform() {
  if (VideoPlayerPlatform.instance is! FlutterpiVideoPlayer) {
    throw StateError(
      '`VideoPlayerPlatform.instance` must be of `FlutterpiVideoPlayer` to use advanced video player features.'
      'Make sure you\'ve called `FlutterpiVideoPlayer.registerWith()` somewhere in main.',
    );
  }
}

FlutterpiVideoPlayer get _platform {
  _checkPlatform();
  return VideoPlayerPlatform.instance as FlutterpiVideoPlayer;
}

extension FlutterpiVideoPlayerControllerAdvancedControls on VideoPlayerController {
  Future<void> fastSeek(Duration position) {
    _platform.seekMode = SeekMode.fast;
    return seekTo(position);
  }

  Future<void> stepForward() async {
    _checkPlatform();

    if (value.isPlaying) {
      await pause();
    }

    // ignore: invalid_use_of_visible_for_testing_member
    await _platform.stepForward(textureId);

    final position = await this.position;
    if (position != null) {
      _platform.seekMode = SeekMode.noop;
      await seekTo(position);
    }
  }

  Future<void> stepBackward() async {
    _checkPlatform();

    if (value.isPlaying) {
      await pause();
    }

    // ignore: invalid_use_of_visible_for_testing_member
    await _platform.stepBackward(textureId);

    final position = await this.position;
    if (position != null) {
      _platform.seekMode = SeekMode.noop;
      await seekTo(position);
    }
  }
}

class FlutterpiVideoPlayerController extends VideoPlayerController {
  FlutterpiVideoPlayerController._network(
    super.dataSource, {
    super.formatHint,
    super.closedCaptionFile,
    super.videoPlayerOptions,
    super.httpHeaders,
  }) : super.networkUrl();

  factory FlutterpiVideoPlayerController.withGstreamerPipeline(
    String pipeline, {
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
    VideoPlayerOptions? videoPlayerOptions,
    Map<String, String> httpHeaders = const <String, String>{},
  }) {
    _checkPlatform();

    return FlutterpiVideoPlayerController._network(
      Uri(
        scheme: FlutterpiVideoPlayer.pipelineUrlScheme,
        path: FlutterpiVideoPlayer.pipelineUrlCodec.encode(pipeline),
      ),
      formatHint: formatHint,
      closedCaptionFile: closedCaptionFile,
      videoPlayerOptions: videoPlayerOptions,
      httpHeaders: httpHeaders,
    );
  }
}
