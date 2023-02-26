# flutterpi_gstreamer_video_player

A video player implementation for [flutter-pi](https://github.com/ardera/flutter-pi).

Note this __only__ works on a Raspberry Pi with flutter-pi and gstreamer installed, not on any other platform, even though though platform tags of the pub.dev package may seem to suggest otherwise.

## Example usage
To use this package in your app, execute `FlutterpiVideoPlayer.registerWith()` in `main`, before the `runApp` call. Ideally you only do this when you're sure the platform code is present.

Example code:
```dart
void main() {
    FlutterpiVideoPlayer.registerWith()
    runApp(MyApp());
}
```

Then you just use the widgets/classes of the official [video_player](https://pub.dev/packages/video_player) package. [chewie](https://github.com/brianegan/chewie) is good for more high-level playback.

## Advanced features

In addition to what the official `video_player` package provides, this video player implementation has some additional features that might be interesting.
The advanced features are also used in the example.

### 1. Playing raw gstreamer pipelines

You can create a `VideoPlayerController` using a raw gstreamer pipeline, like here:

```dart
@override
void initState() {
    _controller = _FlutterpiVideoPlayerController.withGstreamerPipeline('libcamerasrc ! queue ! appsink name="sink"');
    super.initState();
}
```

In this case the video player will show the camera preview using libcamera.

### 2. Single-frame stepping

You can step through the video playback. When `stepForward` or `stepBackward` is called, the video playback will pause.
I.e. you need to call `_controller.play()` again to resume it.

```dart
late VideoPlayerController _controller;

@override
void initState() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );
    super.initState();
}

void stepForward() {
    _controller.stepForward();
}

void stepBackward() {
    _controller.stepBackward();
}
```

### 3. Fast seeking

You can seek to the nearest keyframe instead, which is way faster than seeking to an exact position.

```dart
late VideoPlayerController _controller;

@override
void initState() {
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    );
    super.initState();
}

void doFastSeek() {
    _controller.fastSeek(Duration(seconds: 5));
}
```
