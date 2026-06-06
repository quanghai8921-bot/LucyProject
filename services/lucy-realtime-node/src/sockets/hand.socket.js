const roomService = require('../services/room.service');

function registerHandSocket(io, socket) {
  socket.on('hand:raise', async (payload = {}, ack) => {
    try {
      const { roomId, userId, raised } = payload;
      if (!roomId) throw new Error('roomId is required');
      if (!userId) throw new Error('userId is required');

      const result = await roomService.setHandRaiseState(roomId, payload);
      const participants = await roomService.getParticipants(roomId);
      const user = participants.find((item) => String(item.userId) === String(userId));

      io.to(roomId).emit('hand:raised', {
        roomId,
        userId,
        displayName: user?.displayName || result.displayName,
        raised: result.raised ?? !!raised,
        handRaiseStatus: result.handRaiseStatus,
      });

      ack?.({ success: true, data: result });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'hand:raise', message: error.message });
    }
  });
}

module.exports = registerHandSocket;
