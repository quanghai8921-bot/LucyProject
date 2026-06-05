const socketStateService = require('../services/socket-state.service');

function registerChatSocket(io, socket) {
  socket.on('chat:message', (message) => {
    socketStateService.addMessage(message.roomId, message);
    io.to(message.roomId).emit('chat:message', message);
  });
}

module.exports = registerChatSocket;
