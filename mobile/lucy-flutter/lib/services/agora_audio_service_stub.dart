class AgoraAudioService {
  bool get isJoined => false;

  Future<void> join({
    required String roomId,
    required String userId,
    bool publishMicrophone = false,
  }) async {
    throw UnsupportedError('Agora audio is only available on Flutter Web.');
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    throw UnsupportedError('Agora audio is only available on Flutter Web.');
  }

  Future<void> leave() async {}
}
