const socketStateService = require('../services/socket-state.service');
const roomService = require('../services/room.service');
const crypto = require('crypto');

function registerChatSocket(io, socket) {
  socket.on('chat:message', async (payload = {}, ack) => {
    try {
      const { roomId, userId } = payload;
      const text = String(payload.text ?? payload.message ?? '').trim();
      if (!roomId) throw new Error('roomId is required');
      if (!userId) throw new Error('userId is required');
      if (!text) throw new Error('message text is required');

      const participants = await roomService.getParticipants(roomId);
      let sender = participants.find((item) => String(item.userId) === String(userId));
      if (!sender) {
        const room = await roomService.getRoom(roomId);
        if (String(room.hostUserId) !== String(userId)) {
          throw new Error('User has not joined this room');
        }
        sender = {
          userId,
          displayName: payload.displayName || room.hostFullName || 'Mentor',
          avatarUrl: null,
        };
      }

      const message = {
        messageId: `MSG_${crypto.randomUUID()}`,
        roomId,
        userId,
        displayName: sender.displayName,
        avatarUrl: sender.avatarUrl,
        text,
        createdAt: new Date().toISOString(),
      };
      socketStateService.addMessage(roomId, message);
      io.to(roomId).emit('chat:message', message);
      ack?.({ success: true, data: message });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'chat:message', message: error.message });
    }
  });
}

module.exports = registerChatSocket;
