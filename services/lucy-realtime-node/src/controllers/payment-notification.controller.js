function broadcastPaymentNotification(req, res) {
  const io = req.app.get('io');
  if (!io) {
    return res.status(503).json({ success: false, message: 'Socket server is not ready.' });
  }

  const notification = req.body || {};
  const { userId, UserId, roomId, RoomId, notificationType, NotificationType } = notification;
  const targetUserId = userId || UserId;
  const targetRoomId = roomId || RoomId;
  const type = notificationType || NotificationType;

  if (!targetUserId) {
    return res.status(400).json({ success: false, message: 'UserId is required.' });
  }

  io.to(`user:${targetUserId}`).emit('notification:new', notification);
  io.to(`mentor:${targetUserId}`).emit('notification:new', notification);

  if (targetRoomId && type === 'DONATION') {
    io.to(targetRoomId).emit('payment:donation', notification);
  }

  return res.json({ success: true });
}

module.exports = {
  broadcastPaymentNotification,
};
