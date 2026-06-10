const roomService = require('../services/room.service');

function registerRoomSocket(io, socket) {
  socket.on('mentor:watch', ({ mentorUserId } = {}, ack) => {
    if (!mentorUserId) {
      ack?.({ success: false, message: 'mentorUserId is required' });
      return;
    }
    socket.join(`mentor:${mentorUserId}`);
    ack?.({ success: true, data: { mentorUserId } });
  });

  socket.on('mentor:unwatch', ({ mentorUserId } = {}, ack) => {
    if (mentorUserId) socket.leave(`mentor:${mentorUserId}`);
    ack?.({ success: true, data: { mentorUserId } });
  });

  const watchNotifications = ({ userId } = {}, ack) => {
    if (!userId) {
      ack?.({ success: false, message: 'userId is required' });
      return;
    }
    socket.join(`user:${userId}`);
    ack?.({ success: true, data: { userId } });
  };

  socket.on('user:watch', watchNotifications);
  socket.on('notification:watch', watchNotifications);

  socket.on('room:watch', ({ roomId } = {}, ack) => {
    if (!roomId) {
      ack?.({ success: false, message: 'roomId is required' });
      return;
    }
    socket.join(roomId);
    ack?.({ success: true, data: { roomId } });
  });

  socket.on('room:unwatch', ({ roomId } = {}, ack) => {
    if (roomId) socket.leave(roomId);
    ack?.({ success: true, data: { roomId } });
  });

  socket.on('room:join', async (payload = {}, ack) => {
    try {
      const { roomId } = payload;
      if (!roomId) throw new Error('roomId is required');

      const participant = await roomService.joinRoom(roomId, payload);
      socket.join(roomId);
      socket.data.roomId = roomId;
      socket.data.userId = participant.userId;

      const participants = await roomService.getParticipants(roomId);
      io.to(roomId).emit('room:participant-joined', participant);
      io.to(roomId).emit('room:participants', { roomId, participants });
      io.to(`mentor:${participant.hostUserId}`).emit('mentor:room-updated', {
        roomId,
        participants,
        joinedParticipant: participant,
      });
      ack?.({ success: true, data: { participant, participants } });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'room:join', message: error.message });
    }
  });

  socket.on('room:leave', async (payload = {}, ack) => {
    try {
      const { roomId } = payload;
      if (!roomId) throw new Error('roomId is required');

      const result = await roomService.leaveRoom(roomId, payload);
      socket.leave(roomId);
      const participants = await roomService.getParticipants(roomId);
      io.to(roomId).emit('room:participant-left', result);
      io.to(roomId).emit('room:participants', { roomId, participants });
      io.to(`mentor:${result.hostUserId}`).emit('mentor:room-updated', { roomId, participants, leftParticipant: result });
      ack?.({ success: true, data: result });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'room:leave', message: error.message });
    }
  });

  socket.on('room:end', async (payload = {}, ack) => {
    try {
      const { roomId } = payload;
      if (!roomId) throw new Error('roomId is required');

      io.to(roomId).emit('room:ended', { roomId });

      const clients = io.sockets.adapter.rooms.get(roomId);
      if (clients) {
        for (const clientId of clients) {
          const clientSocket = io.sockets.sockets.get(clientId);
          if (clientSocket) {
            clientSocket.leave(roomId);
            clientSocket.data.roomId = null;
          }
        }
      }

      ack?.({ success: true });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'room:end', message: error.message });
    }
  });

  socket.on('disconnect', async () => {
    const { roomId, userId } = socket.data;
    if (!roomId || !userId) return;
    try {
      const result = await roomService.leaveRoom(roomId, { userId });
      const participants = await roomService.getParticipants(roomId);
      io.to(roomId).emit('room:participant-left', result);
      io.to(roomId).emit('room:participants', { roomId, participants });
      io.to(`mentor:${result.hostUserId}`).emit('mentor:room-updated', { roomId, participants, leftParticipant: result });
    } catch (_) {
      // Ignore disconnect cleanup errors; REST state remains the source of truth.
    }
  });
}

module.exports = registerRoomSocket;
