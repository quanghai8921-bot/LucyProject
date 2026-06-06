import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

typedef JsonMap = Map<String, dynamic>;

class RealtimeSocketService {
  RealtimeSocketService({
    String? baseUrl,
  }) : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'LUCY_REALTIME_URL',
              defaultValue: 'http://localhost:3004',
            );

  final String baseUrl;
  io.Socket? _socket;

  io.Socket get socket {
    final current = _socket;
    if (current != null) return current;

    final created = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _socket = created;
    return created;
  }

  void connect() {
    if (!socket.connected) socket.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void watchMentor(String mentorUserId) {
    connect();
    socket.emit('mentor:watch', {'mentorUserId': mentorUserId});
  }

  void unwatchMentor(String mentorUserId) {
    _socket?.emit('mentor:unwatch', {'mentorUserId': mentorUserId});
  }

  void watchRoom(String roomId) {
    connect();
    socket.emit('room:watch', {'roomId': roomId});
  }

  void unwatchRoom(String roomId) {
    _socket?.emit('room:unwatch', {'roomId': roomId});
  }

  Future<JsonMap> joinRoom({
    required String roomId,
    required String userId,
    String? displayName,
  }) {
    return _emitWithAck('room:join', {
      'roomId': roomId,
      'userId': userId,
      if (displayName != null && displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
    });
  }

  void leaveRoom({
    required String roomId,
    required String userId,
  }) {
    _socket?.emit('room:leave', {'roomId': roomId, 'userId': userId});
  }

  void sendMessage({
    required String roomId,
    required String userId,
    required String text,
    String? displayName,
  }) {
    socket.emit('chat:message', {
      'roomId': roomId,
      'userId': userId,
      'text': text,
      if (displayName != null && displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
    });
  }

  void raiseHand({
    required String roomId,
    required String userId,
    required bool raised,
  }) {
    socket.emit('hand:raise', {'roomId': roomId, 'userId': userId, 'raised': raised});
  }

  Future<JsonMap> toggleMic({
    required String roomId,
    required String userId,
    required bool enabled,
    String? displayName,
  }) {
    return _emitWithAck('mic:toggle', {
      'roomId': roomId,
      'userId': userId,
      'enabled': enabled,
      if (displayName != null && displayName.trim().isNotEmpty) 'displayName': displayName.trim(),
    });
  }

  void onMentorRoomUpdated(void Function(JsonMap payload) handler) {
    socket.on('mentor:room-updated', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void endRoom(String roomId) {
    _socket?.emit('room:end', {'roomId': roomId});
  }

  void onRoomEnded(void Function(JsonMap payload) handler) {
    socket.on('room:ended', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void offRoomEnded() {
    _socket?.off('room:ended');
  }

  void onMicChanged(void Function(JsonMap payload) handler) {
    socket.on('mic:changed', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void offMicChanged() {
    _socket?.off('mic:changed');
  }

  void onChatMessage(void Function(JsonMap payload) handler) {
    socket.on('chat:message', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void offChatMessage() {
    _socket?.off('chat:message');
  }

  void onHandRaised(void Function(JsonMap payload) handler) {
    socket.on('hand:raised', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void offHandRaised() {
    _socket?.off('hand:raised');
  }

  void pinSlide({
    required String roomId,
    required String userId,
    required String filename,
    required String fileBase64,
    required String fileType,
  }) {
    final payload = {
      'roomId': roomId,
      'userId': userId,
      'filename': filename,
      'fileBase64': fileBase64,
      'fileType': fileType,
    };
    socket.emit('material:pin', payload);
  }

  void onSlidePinned(void Function(JsonMap payload) handler) {
    socket.on('material:pinned', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
    socket.on('slide:pinned', (payload) {
      if (payload is Map) handler(Map<String, dynamic>.from(payload));
    });
  }

  void offSlidePinned() {
    _socket?.off('material:pinned');
    _socket?.off('slide:pinned');
  }

  Future<JsonMap> _emitWithAck(
    String event,
    JsonMap payload, {
    Duration timeout = const Duration(seconds: 8),
  }) {
    connect();
    final completer = Completer<JsonMap>();

    void completeOnce(JsonMap value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    socket.emitWithAck(event, payload, ack: (response) {
      if (response is Map) {
        final data = Map<String, dynamic>.from(response);
        final success = data['success'];
        if (success == false) {
          final message = '${data['message'] ?? 'Realtime request failed.'}';
          if (!completer.isCompleted) completer.completeError(Exception(message));
          return;
        }
        completeOnce(data);
        return;
      }
      completeOnce(<String, dynamic>{'success': true, 'data': response});
    });

    return completer.future.timeout(timeout, onTimeout: () {
      throw TimeoutException('Realtime server did not acknowledge $event.', timeout);
    });
  }
}
