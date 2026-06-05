const socketStateService = require('../services/socket-state.service');

function registerMicSocket(io, socket) {
  socket.on('mic:toggle', ({ roomId, userId, muted }) => {
    socketStateService.setMicState(roomId, userId, muted);
    io.to(roomId).emit('mic:changed', { roomId, userId, muted: Boolean(muted) });
  });
}

module.exports = registerMicSocket;
