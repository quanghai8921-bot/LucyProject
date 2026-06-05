const socketStateService = require('../services/socket-state.service');

function registerAttendanceSocket(io, socket) {
  socket.on('attendance:mark', ({ roomId, userId, status }) => {
    socketStateService.markAttendance(roomId, userId, status);
    io.to(roomId).emit('attendance:changed', { roomId, userId, status });
  });
}

module.exports = registerAttendanceSocket;
