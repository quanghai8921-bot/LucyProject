import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:http/http.dart' as http;

class AgoraAudioService {
  AgoraAudioService({http.Client? client, String? realtimeBaseUrl})
      : _client = client ?? http.Client(),
        realtimeBaseUrl = realtimeBaseUrl ??
            const String.fromEnvironment(
              'LUCY_REALTIME_URL',
              defaultValue: 'http://localhost:3004',
            );

  final http.Client _client;
  final String realtimeBaseUrl;

  Object? _agora;
  Object? _rtcClient;
  Object? _localAudioTrack;
  bool _joined = false;
  bool _publishInProgress = false;

  bool get isJoined => _joined;

  Future<void> join({
    required String roomId,
    required String userId,
    bool publishMicrophone = false,
  }) async {
    if (_joined) {
      if (publishMicrophone) {
        await setMicrophoneEnabled(true);
      }
      return;
    }

    final tokenInfo = await _fetchRtcToken(roomId: roomId, userId: userId);
    _agora = js_util.getProperty(html.window, 'AgoraRTC');
    if (_agora == null || js_util.hasProperty(_agora!, 'createClient') == false) {
      throw AgoraAudioException(
        'Agora Web SDK chua duoc tai. Kiem tra script AgoraRTC_N trong web/index.html.',
      );
    }

    _rtcClient = js_util.callMethod(
      _agora!,
      'createClient',
      [
        js_util.jsify({'mode': 'rtc', 'codec': 'vp8'}),
      ],
    );
    _registerClientEvents(_rtcClient!);

    await js_util.promiseToFuture(js_util.callMethod(_rtcClient!, 'join', [
      tokenInfo.appId,
      tokenInfo.channelName,
      tokenInfo.token,
      tokenInfo.uid,
    ]));
    _joined = true;

    if (publishMicrophone) {
      await setMicrophoneEnabled(true);
    }
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (!_joined || _rtcClient == null) {
      throw AgoraAudioException('Chua ket noi Agora RTC.');
    }

    if (!enabled) {
      final track = _localAudioTrack;
      if (track != null && js_util.hasProperty(track, 'setEnabled')) {
        await js_util.promiseToFuture(js_util.callMethod(track, 'setEnabled', [false]));
      }
      return;
    }

    final existingTrack = _localAudioTrack;
    if (existingTrack != null) {
      await js_util.promiseToFuture(js_util.callMethod(existingTrack, 'setEnabled', [true]));
      return;
    }

    if (_publishInProgress) return;
    _publishInProgress = true;
    try {
      final audioTrack = await js_util.promiseToFuture<Object>(
        js_util.callMethod(_agora!, 'createMicrophoneAudioTrack', []),
      );
      _localAudioTrack = audioTrack;
      await js_util.promiseToFuture(js_util.callMethod(_rtcClient!, 'publish', [audioTrack]));
    } finally {
      _publishInProgress = false;
    }
  }

  Future<void> leave() async {
    final track = _localAudioTrack;
    final client = _rtcClient;

    _localAudioTrack = null;
    _rtcClient = null;
    _joined = false;

    if (track != null) {
      try {
        if (client != null) {
          await js_util.promiseToFuture(js_util.callMethod(client, 'unpublish', [track]));
        }
      } catch (_) {}
      try {
        js_util.callMethod(track, 'stop', []);
      } catch (_) {}
      try {
        js_util.callMethod(track, 'close', []);
      } catch (_) {}
    }

    if (client != null) {
      try {
        await js_util.promiseToFuture(js_util.callMethod(client, 'leave', []));
      } catch (_) {}
    }
  }

  void _registerClientEvents(Object client) {
    js_util.callMethod(client, 'on', [
      'user-published',
      js.allowInterop((dynamic user, dynamic mediaType) {
        unawaited(_subscribeRemoteUser(user, '$mediaType'));
      }),
    ]);
    js_util.callMethod(client, 'on', [
      'user-unpublished',
      js.allowInterop((dynamic user, dynamic mediaType) {
        if ('$mediaType' == 'audio' && js_util.hasProperty(user, 'audioTrack')) {
          final audioTrack = js_util.getProperty(user, 'audioTrack');
          if (audioTrack != null && js_util.hasProperty(audioTrack, 'stop')) {
            js_util.callMethod(audioTrack, 'stop', []);
          }
        }
      }),
    ]);
  }

  Future<void> _subscribeRemoteUser(dynamic user, String mediaType) async {
    if (mediaType != 'audio' || _rtcClient == null) return;
    await js_util.promiseToFuture(js_util.callMethod(_rtcClient!, 'subscribe', [user, mediaType]));
    final audioTrack = js_util.getProperty(user, 'audioTrack');
    if (audioTrack != null && js_util.hasProperty(audioTrack, 'play')) {
      js_util.callMethod(audioTrack, 'play', []);
    }
  }

  Future<_AgoraTokenInfo> _fetchRtcToken({
    required String roomId,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$realtimeBaseUrl/api/realtime/agora/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'roomId': roomId, 'userId': userId}),
    );
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    if (response.statusCode < 200 || response.statusCode >= 300 || map['success'] == false) {
      throw AgoraAudioException('${map['message'] ?? 'Khong lay duoc Agora token.'}');
    }

    final data = map['data'] as Map<String, dynamic>? ?? map;
    return _AgoraTokenInfo(
      appId: '${data['appId'] ?? ''}',
      channelName: '${data['channelName'] ?? roomId}',
      uid: '${data['uid'] ?? userId}',
      token: '${data['token'] ?? ''}',
    );
  }
}

class _AgoraTokenInfo {
  const _AgoraTokenInfo({
    required this.appId,
    required this.channelName,
    required this.uid,
    required this.token,
  });

  final String appId;
  final String channelName;
  final String uid;
  final String token;
}

class AgoraAudioException implements Exception {
  const AgoraAudioException(this.message);

  final String message;

  @override
  String toString() => message;
}
