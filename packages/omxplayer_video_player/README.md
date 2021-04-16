# omxplayer_video_player
A package that implements [`video_player_platform_interface`](https://pub.dev/packages/video_player_platform_interface) using [`omxplayer`](https://www.raspberrypi.org/documentation/raspbian/applications/omxplayer.md) and platform views.
Note this __only__ works on a Raspberry Pi with flutter-pi, not on any other platform, even though though platform tags of the pub.dev package seem to suggest otherwise.

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