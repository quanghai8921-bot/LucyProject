const socketStateService = require('../services/socket-state.service');

function registerRoomSocket(io, socket) {
  socket.on('room:join', ({ roomId, userId, ...data }) => {
    socket.join(roomId);
    socketStateService.addParticipant(roomId, userId, data);
    io.to(roomId).emit('room:participant-joined', { roomId, userId, ...data });
  });

  socket.on('room:leave', ({ roomId, userId }) => {
    socket.leave(roomId);
    socketStateService.removeParticipant(roomId, userId);
    io.to(roomId).emit('room:participant-left', { roomId, userId });
  });
}

module.exports = registerRoomSocket;
