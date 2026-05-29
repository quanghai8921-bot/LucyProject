const javaLmsService = require('./java-lms.service');
const socketStateService = require('./socket-state.service');

async function createRoom(payload) {
  return javaLmsService.createRoom(payload);
}

async function getRoom(roomId) {
  return javaLmsService.getRoom(roomId);
}

async function joinRoom(roomId, payload) {
  socketStateService.addParticipant(roomId, payload.userId, payload);
  return {
    roomId,
    userId: payload.userId,
    joined: true,
  };
}

async function leaveRoom(roomId, payload) {
  socketStateService.removeParticipant(roomId, payload.userId);
  return {
    roomId,
    userId: payload.userId,
    left: true,
  };
}

module.exports = {
  createRoom,
  getRoom,
  joinRoom,
  leaveRoom,
};
