const rooms = new Map();

function ensureRoom(roomId) {
  if (!rooms.has(roomId)) {
    rooms.set(roomId, {
      participants: new Map(),
      messages: [],
      micStates: new Map(),
      attendance: new Map(),
    });
  }

  return rooms.get(roomId);
}

function addParticipant(roomId, userId, data = {}) {
  const room = ensureRoom(roomId);
  room.participants.set(String(userId), {
    userId,
    ...data,
    joinedAt: new Date().toISOString(),
  });
}

function removeParticipant(roomId, userId) {
  const room = ensureRoom(roomId);
  room.participants.delete(String(userId));
}

function addMessage(roomId, message) {
  const room = ensureRoom(roomId);
  room.messages.push({
    ...message,
    createdAt: new Date().toISOString(),
  });
}

function setMicState(roomId, userId, muted) {
  const room = ensureRoom(roomId);
  room.micStates.set(String(userId), Boolean(muted));
}

function markAttendance(roomId, userId, status) {
  const room = ensureRoom(roomId);
  room.attendance.set(String(userId), {
    userId,
    status,
    updatedAt: new Date().toISOString(),
  });
}

function getRoomState(roomId) {
  const room = ensureRoom(roomId);

  return {
    roomId,
    participants: Array.from(room.participants.values()),
    messages: room.messages,
    micStates: Object.fromEntries(room.micStates),
    attendance: Array.from(room.attendance.values()),
  };
}

module.exports = {
  addParticipant,
  removeParticipant,
  addMessage,
  setMicState,
  markAttendance,
  getRoomState,
};
