library omxplayer_video_player;

import 'dart:ffi' as ffi;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import 'package:video_player_platform_interface/video_player_platform_interface.dart';

part 'platform_interface.dart';
part 'omxplayer_view.dart';
part 'ensure_unique.dart';

class _OmxplayerKey extends GlobalObjectKey {
  _OmxplayerKey(int playerId) : super(playerId);
}

/// A video player platform that uses `omxplayer` and platform views
/// to display videos. This has platform-side dependencies that are not
/// included in this package.
class OmxplayerVideoPlayer extends VideoPlayerPlatform {
  OmxplayerVideoPlayer._(this._strictViewBehaviour);

  final bool _strictViewBehaviour;

  @override
  Future<void> init() => _PlatformInterface.instance.init();

  @override
  Future<void> dispose(int textureId) => _PlatformInterface.instance.dispose(textureId);

  @override
  Future<int?> create(DataSource dataSource) => _PlatformInterface.instance.create(dataSource);

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) => _PlatformInterface.instance.videoEventsFor(textureId);

  @override
  Future<void> setLooping(int textureId, bool looping) => _PlatformInterface.instance.setLooping(textureId, looping);

  @override
  Future<void> play(int textureId) => _PlatformInterface.instance.play(textureId);

  @override
  Future<void> pause(int textureId) => _PlatformInterface.instance.pause(textureId);

  @override
  Future<void> setVolume(int textureId, double volume) => _PlatformInterface.instance.setVolume(textureId, volume);

  @override
  Future<void> seekTo(int textureId, Duration position) => _PlatformInterface.instance.seekTo(textureId, position);

  /// TODO(ardera): Implement setPlaybackSpeed
  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) => Future.value();

  @override
  Future<Duration> getPosition(int textureId) => _PlatformInterface.instance.getPosition(textureId);

  @override

  /// Omxplayer can only have one view, which is a difference to most other
  /// video player implementations.
  Widget buildView(int textureId) {
    return EnsureUnique(
        strict: this._strictViewBehaviour,
        identity: _OmxplayerKey(textureId),
        child: OmxplayerView(
          key: _OmxplayerKey(textureId),
          playerId: textureId,
        ));
  }

  /// Sets up [OmxplayerViewPlayer] as the [VideoPlayerPlatform.instance],
  /// i.e. the backend to be used for video playback.
  /// When [strictViewBehaviour] is `true`, all views of a player instance will be given
  /// [GlobalObjectKeys]s to ensure that at most a single video view for a player instance
  /// is mounted in the widget tree at a time.
  /// When [strictViewBehaviour] is `false`, will try to work around that issue and
  /// only actually build the platform view for the last-recently registered element.
  static void useAsImplementation({bool strictViewBehaviour: false}) {
    VideoPlayerPlatform.instance = OmxplayerVideoPlayer._(strictViewBehaviour);
  }

  static bool isPlatformSidePresent() => _PlatformInterface.instance.isPlatformSidePresent();
}
