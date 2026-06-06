const roomService = require('../services/room.service');

function registerMicSocket(io, socket) {
  socket.on('mic:toggle', async (payload = {}, ack) => {
    try {
      const { roomId } = payload;
      if (!roomId) throw new Error('roomId is required');

      const state = await roomService.setMicState(roomId, payload);
      const participants = await roomService.getParticipants(roomId);
      io.to(roomId).emit('mic:changed', state);
      io.to(roomId).emit('room:participants', { roomId, participants });
      io.to(`mentor:${state.hostUserId}`).emit('mentor:room-updated', { roomId, participants });
      ack?.({ success: true, data: state });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'mic:toggle', message: error.message });
    }
  });
}

module.exports = registerMicSocket;
