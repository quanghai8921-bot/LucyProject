async function createRtcToken(payload) {
  return {
    appId: process.env.AGORA_APP_ID || '',
    channelName: payload.channelName,
    uid: payload.uid,
    token: null,
    expiresIn: payload.expiresIn || 3600,
  };
}

async function startRecording(roomId, payload) {
  return {
    roomId,
    recordingId: null,
    status: 'starting',
    options: payload,
  };
}

async function stopRecording(roomId, payload) {
  return {
    roomId,
    recordingId: payload.recordingId,
    status: 'stopping',
  };
}

module.exports = {
  createRtcToken,
  startRecording,
  stopRecording,
};
