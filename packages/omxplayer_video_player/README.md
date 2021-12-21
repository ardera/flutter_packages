# omxplayer_video_player
A backend for the official flutter [video_player](https://pub.dev/packages/video_player) based on [`omxplayer`](https://www.raspberrypi.org/documentation/raspbian/applications/omxplayer.md) and platform views.

Note this __only__ works on a Raspberry Pi with flutter-pi and omxplayer installed, not on any other platform, even though though platform tags of the pub.dev package seem to suggest otherwise.

## Example usage
To use this package in your app, execute `OmxplayerVideoPlayer.useAsImplementation()` in `main`, before the `runApp` call. Ideally you only do this when you're sure the platform code is present. You can check that using `OmxplayerVideoPlayer.isPlatformSidePresent()`.

Example code:
```dart
void main() {
    if (OmxplayerVideoPlayer.isPlatformSidePresent()) {
        OmxplayerVideoPlayer.useAsImplementation();
    }
    runApp(MyApp());
}
```

Then you just use the widgets/classes of the official [video_player](https://pub.dev/packages/video_player) package. [chewie](https://github.com/brianegan/chewie) might or might not work. It draws multiple video views when going into fullscreen mode, which is hard to do with omxplayer. (You can't tell omxplayer to draw two views)
