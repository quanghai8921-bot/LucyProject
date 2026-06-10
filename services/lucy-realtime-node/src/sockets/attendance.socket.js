const roomService = require('../services/room.service');

function registerAttendanceSocket(io, socket) {
  socket.on('hand:raise', async (payload = {}, ack) => {
    try {
      const { roomId } = payload;
      if (!roomId) throw new Error('roomId is required');

      const state = await roomService.setHandRaiseState(roomId, payload);
      const participants = await roomService.getParticipants(roomId);
      io.to(roomId).emit('hand:changed', state);
      io.to(roomId).emit('room:participants', { roomId, participants });
      io.to(`mentor:${state.hostUserId}`).emit('mentor:room-updated', { roomId, participants });
      ack?.({ success: true, data: state });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'hand:raise', message: error.message });
    }
  });

  socket.on('attendance:mark', async (payload = {}, ack) => {
    try {
      const { roomId, userId, status } = payload;
      if (!roomId) throw new Error('roomId is required');
      const state = await roomService.setHandRaiseState(roomId, {
        userId,
        raised: status === 'RAISED',
      });
      io.to(roomId).emit('attendance:changed', { roomId, userId, status: state.handRaiseStatus });
      ack?.({ success: true, data: state });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'attendance:mark', message: error.message });
    }
  });
}

module.exports = registerAttendanceSocket;
