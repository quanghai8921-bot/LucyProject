const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

async function createRtcToken(payload) {
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;
  const channelName = String(payload.channelName || payload.roomId || '').trim();
  const uid = String(payload.uid || payload.userId || '').trim();
  const expiresIn = Number(payload.expiresIn || process.env.AGORA_TOKEN_EXPIRES_IN || 3600);

  if (!appId || !appCertificate) {
    const error = new Error('Agora app id/certificate is not configured');
    error.statusCode = 500;
    throw error;
  }
  if (!channelName) {
    const error = new Error('channelName or roomId is required');
    error.statusCode = 400;
    throw error;
  }
  if (!uid) {
    const error = new Error('uid or userId is required');
    error.statusCode = 400;
    throw error;
  }

  const now = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = now + expiresIn;
  const token = RtcTokenBuilder.buildTokenWithAccount(
    appId,
    appCertificate,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpireTime,
  );

  return {
    appId,
    channelName,
    uid,
    token,
    expiresIn,
    expireAt: new Date(privilegeExpireTime * 1000).toISOString(),
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
