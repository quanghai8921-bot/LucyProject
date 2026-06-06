function registerSlideSocket(io, socket) {
  const pinMaterial = async (payload = {}, ack, eventName = 'material:pinned') => {
    try {
      const { roomId, userId, filename, fileBase64, fileType } = payload;
      if (!roomId) throw new Error('roomId is required');
      if (!userId) throw new Error('userId is required');
      if (!filename) throw new Error('filename is required');

      const material = {
        roomId,
        userId,
        filename,
        fileBase64,
        fileType,
        pinnedAt: new Date().toISOString(),
      };

      io.to(roomId).emit(eventName, material);

      ack?.({ success: true, data: { filename } });
    } catch (error) {
      ack?.({ success: false, message: error.message });
      socket.emit('socket:error', { event: 'material:pin', message: error.message });
    }
  };

  socket.on('material:pin', (payload, ack) => pinMaterial(payload, ack, 'material:pinned'));
  socket.on('slide:pin', (payload, ack) => pinMaterial(payload, ack, 'slide:pinned'));
}

module.exports = registerSlideSocket;
