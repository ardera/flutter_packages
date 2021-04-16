part of omxplayer_video_player;

typedef omxpvidpp_is_present_func = ffi.Int8 Function();
typedef OmxpvidppIsPresent = int Function();

class _PlatformInterface {
  _PlatformInterface._constructor(this._isPlatformSidePresent);

  factory _PlatformInterface._() {
    final lib = ffi.DynamicLibrary.process();

    try {
      final isPresent = lib.lookupFunction<omxpvidpp_is_present_func, OmxpvidppIsPresent>("omxpvidpp_is_present");
      return _PlatformInterface._constructor(isPresent);
    } on ArgumentError {
      return _PlatformInterface._constructor(null);
    }
  }

  final OmxpvidppIsPresent? _isPlatformSidePresent;

  static const _channel = MethodChannel("flutter.io/omxplayerVideoPlayer");
  static _PlatformInterface? _instance;

  static _PlatformInterface get instance {
    if (_instance == null) {
      _instance = _PlatformInterface._();
    }

    return _instance!;
  }

  Future<void> init() {
    return Future.value();
  }

  Future<void> dispose(int playerId) {
    return _channel.invokeMethod<void>('dispose', {'playerId': playerId});
  }

  Future<int?> create(DataSource dataSource) {
    return _channel.invokeMethod<int>('create', {
      'sourceType': dataSource.sourceType.toString(),
      'uri': dataSource.uri.toString(),
      'asset': dataSource.asset,
      'package': dataSource.package,
      'formatHint': dataSource.formatHint.toString()
    });
  }

  Stream<VideoEvent> videoEventsFor(int playerId) {
    return EventChannel('flutter.io/omxplayerVideoPlayer/videoEvents$playerId')
        .receiveBroadcastStream()
        .map((dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration']),
            size: Size(map['width']?.toDouble() ?? 0.0, map['height']?.toDouble() ?? 0.0),
          );
        case 'completed':
          return VideoEvent(
            eventType: VideoEventType.completed,
          );
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'];

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

  Future<void> setLooping(int playerId, bool looping) {
    return _channel.invokeMethod<void>('setLooping', {'playerId': playerId, 'looping': looping});
  }

  Future<void> play(int playerId) {
    return _channel.invokeMethod<void>('play', {
      'playerId': playerId,
    });
  }

  Future<void> pause(int playerId) {
    return _channel.invokeMethod<void>('pause', {
      'playerId': playerId,
    });
  }

  Future<void> setVolume(int playerId, double volume) {
    return _channel.invokeMethod<void>('setVolume', {'playerId': playerId, 'volume': volume});
  }

  Future<void> seekTo(int playerId, Duration position) {
    return _channel.invokeMethod<void>('seekTo', {'playerId': playerId, 'position': position.inMilliseconds});
  }

  Future<Duration> getPosition(int playerId) async {
    final result = (await _channel.invokeMethod<int>('getPosition', {'playerId': playerId}))!;
    return Duration(milliseconds: result);
  }

  Future<void> createPlatformView(int playerId, int platformViewId) {
    return _channel.invokeMethod<void>('createPlatformView', {'playerId': playerId, 'platformViewId': platformViewId});
  }

  Future<void> disposePlatformView(int playerId, int platformViewId) {
    return _channel.invokeMethod<void>('disposePlatformView', {'playerId': playerId, 'platformViewId': platformViewId});
  }

  DurationRange _toDurationRange(dynamic value) {
    final List<dynamic> pair = value;
    return DurationRange(
      Duration(milliseconds: pair[0]),
      Duration(milliseconds: pair[1]),
    );
  }

  bool isPlatformSidePresent() {
    if (this._isPlatformSidePresent != null) {
      return this._isPlatformSidePresent!() != 0;
    } else {
      return false;
    }
  }
}
