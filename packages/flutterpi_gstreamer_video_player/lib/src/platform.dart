import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

enum SeekMode {
  /// Indicates the next seek should be a normal (closest frame) seek.
  normal,

  /// Indicates the next seek should be a fast (nearest keyframe) seek.
  fast,

  /// Indicates the next seek should be a noop. No native call will be dispatched.
  noop
}

class FlutterpiVideoPlayer extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = FlutterpiVideoPlayer();
  }

  static const channel = MethodChannel('flutter-pi/gstreamerVideoPlayer');

  Future<T?> _invoke<T>(String method, [dynamic arguments]) {
    return channel.invokeMethod<T>(method, arguments);
  }

  @override
  Future<void> init() async {
    return await _invoke('initialize');
  }

  @override
  Future<void> dispose(int playerId) async {
    return await _invoke('dispose', playerId);
  }

  static const pipelineUrlScheme = 'gstreamerPipeline';
  static final pipelineUrlCodec = utf8.fuse(base64Url);

  @override
  Future<int?> create(DataSource dataSource) async {
    String? asset;
    String? packageName;
    String? uri;
    String? formatHint;
    Map<String, String>? httpHeaders;
    String? gstreamerPipeline;

    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        asset = dataSource.asset;
        packageName = dataSource.package;
        break;
      case DataSourceType.network:
        final parsed = Uri.parse(dataSource.uri!);
        if (parsed.isScheme(pipelineUrlScheme)) {
          // We do the decoding here instead of in flutter-pi because this is one line in dart, in C it's probably 50.
          gstreamerPipeline = pipelineUrlCodec.decode(parsed.path);
          formatHint = _videoFormatStringMap[dataSource.formatHint];
          httpHeaders = dataSource.httpHeaders.isNotEmpty ? dataSource.httpHeaders : null;
        } else {
          uri = dataSource.uri!;
          formatHint = _videoFormatStringMap[dataSource.formatHint];
          httpHeaders = dataSource.httpHeaders.isNotEmpty ? dataSource.httpHeaders : null;
        }
        break;
      case DataSourceType.file:
        uri = dataSource.uri;
        break;
      case DataSourceType.contentUri:
        assert(false);
        break;
    }

    return await _invoke(
      'create',
      [
        asset,
        packageName,
        uri,
        formatHint,
        httpHeaders,
        gstreamerPipeline,
      ],
    );
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {
    return await _invoke('setLooping', [playerId, looping]);
  }

  @override
  Future<void> play(int playerId) async {
    return await _invoke('play', playerId);
  }

  @override
  Future<void> pause(int playerId) async {
    return await _invoke('pause', playerId);
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {
    return await _invoke('setVolume', [playerId, volume]);
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {
    assert(speed > 0);

    return await _invoke('setPlaybackSpeed', [playerId, speed]);
  }

  /// Controls the behaviour of [seekTo]. (Dirty workaround because sanely extending VideoPlayerController is hard.)
  ///
  /// See [SeekMode] for a description of the individual values.
  ///
  /// [seekTo] will reset this flag back to [SeekMode.normal] once it's called, even if the seek fails for whatever
  /// reason.
  var seekMode = SeekMode.normal;

  @override
  Future<void> seekTo(int playerId, Duration position) async {
    late Future<void> future;

    switch (seekMode) {
      case SeekMode.normal:
        future = _invoke(
          'seekTo',
          [playerId, position.inMilliseconds],
        );
        break;
      case SeekMode.fast:
        try {
          future = _invoke('fastSeek', [playerId, position.inMilliseconds]);
        } finally {
          seekMode = SeekMode.normal;
        }
        break;
      case SeekMode.noop:
        future = Future.value(null);
        seekMode = SeekMode.normal;
        break;
    }

    return await future;
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    final millis = await _invoke('getPosition', playerId);
    return Duration(milliseconds: millis);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _eventChannelFor(playerId).receiveBroadcastStream().map((dynamic event) {
      final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
            size: Size((map['width'] as num?)?.toDouble() ?? 0.0, (map['height'] as num?)?.toDouble() ?? 0.0),
            rotationCorrection: map['rotationCorrection'] as int? ?? 0,
          );
        case 'completed':
          return VideoEvent(
            eventType: VideoEventType.completed,
          );
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'] as List<dynamic>;

          return VideoEvent(
            buffered: values.map<DurationRange>(_toDurationRange).toList(),
            eventType: VideoEventType.bufferingUpdate,
          );
        case 'bufferingStart':
          return VideoEvent(eventType: VideoEventType.bufferingStart);
        case 'bufferingEnd':
          return VideoEvent(eventType: VideoEventType.bufferingEnd);
        default:
          return VideoEvent(eventType: VideoEventType.unknown);
      }
    });
  }

  @override
  Widget buildView(int playerId) {
    return Texture(textureId: playerId);
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {
    return await _invoke('setMixWithOthers', mixWithOthers);
  }

  Future<void> stepForward(int textureId) async {
    return await _invoke('stepForward', textureId);
  }

  Future<void> stepBackward(int textureId) async {
    return await _invoke('stepBackward', textureId);
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel('flutter.io/videoPlayer/videoEvents$textureId');
  }

  static const Map<VideoFormat, String> _videoFormatStringMap = <VideoFormat, String>{
    VideoFormat.ss: 'ss',
    VideoFormat.hls: 'hls',
    VideoFormat.dash: 'dash',
    VideoFormat.other: 'other',
  };

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value as List<dynamic>;
    return DurationRange(
      Duration(milliseconds: pair[0] as int),
      Duration(milliseconds: pair[1] as int),
    );
  }
}
