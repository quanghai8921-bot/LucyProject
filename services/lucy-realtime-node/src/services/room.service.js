const javaLmsService = require('./java-lms.service');
const socketStateService = require('./socket-state.service');
const db = require('../config/db');
const crypto = require('crypto');

async function createRoom(payload) {
  return javaLmsService.createRoom(payload);
}

async function getRoom(roomId) {
  const [rows] = await db.query(
    `SELECT r.RoomId AS roomId, r.HostUserId AS hostUserId, r.RoomTitle AS roomTitle,
            r.RoomStatus AS roomStatus, r.MaxParticipants AS maxParticipants,
            r.LanguageId AS languageId, r.LevelId AS levelId, u.FullName AS hostFullName
       FROM Rooms r
       INNER JOIN Users u ON u.UserId = r.HostUserId
      WHERE r.RoomId = ?
      LIMIT 1`,
    [roomId],
  );

  if (!rows.length) {
    const error = new Error('Room not found');
    error.statusCode = 404;
    throw error;
  }

  return rows[0];
}

async function joinRoom(roomId, payload) {
  const userId = requireUserId(payload);
  const room = await getJoinableRoom(roomId);
  const participant = await upsertParticipant(roomId, userId, {
    micStatus: 'OFF',
    handRaiseStatus: 'NONE',
    participantStatus: 'JOINED',
  });
  const profile = await getParticipantProfile(userId, room.hostUserId);
  const result = {
    roomId,
    hostUserId: room.hostUserId,
    userId,
    participantId: participant.participantId,
    micStatus: participant.micStatus,
    handRaiseStatus: participant.handRaiseStatus,
    participantStatus: participant.participantStatus,
    ...profile,
    joined: true,
  };
  socketStateService.addParticipant(roomId, userId, result);
  return result;
}

async function leaveRoom(roomId, payload) {
  const userId = requireUserId(payload);
  const room = await getRoom(roomId);
  const profile = await getParticipantProfile(userId, room.hostUserId);
  await db.query(
    `UPDATE RoomParticipants
        SET LeftAt = NOW(), LastSeenAt = NOW(), ParticipantStatus = 'LEFT', MicStatus = 'OFF', HandRaiseStatus = 'NONE'
      WHERE RoomId = ? AND UserId = ? AND ParticipantStatus = 'JOINED'`,
    [roomId, userId],
  );
  socketStateService.removeParticipant(roomId, userId);
  return {
    roomId,
    hostUserId: room.hostUserId,
    userId,
    left: true,
    ...profile,
  };
}

async function setMicState(roomId, payload) {
  const userId = requireUserId(payload);
  const room = await getRoom(roomId);
  const profile = await getParticipantProfile(userId, room.hostUserId);
  const enabled = Boolean(payload.enabled ?? payload.micEnabled ?? !payload.muted);
  const micStatus = enabled ? 'ON' : 'OFF';
  if (String(userId) !== String(room.hostUserId)) {
    await ensureActiveParticipant(roomId, userId);
    await db.query(
      `UPDATE RoomParticipants SET MicStatus = ?, LastSeenAt = NOW() WHERE RoomId = ? AND UserId = ? AND ParticipantStatus = 'JOINED'`,
      [micStatus, roomId, userId],
    );
  }
  socketStateService.setMicState(roomId, userId, enabled);
  return { roomId, hostUserId: room.hostUserId, userId, micStatus, micEnabled: enabled, ...profile };
}

async function setHandRaiseState(roomId, payload) {
  const userId = requireUserId(payload);
  const room = await getRoom(roomId);
  const profile = await getParticipantProfile(userId, room.hostUserId);
  const raised = Boolean(payload.raised ?? payload.handRaised);
  const handRaiseStatus = raised ? 'RAISED' : 'NONE';
  await ensureActiveParticipant(roomId, userId);
  await db.query(
    `UPDATE RoomParticipants SET HandRaiseStatus = ?, LastSeenAt = NOW() WHERE RoomId = ? AND UserId = ? AND ParticipantStatus = 'JOINED'`,
    [handRaiseStatus, roomId, userId],
  );
  socketStateService.markAttendance(roomId, userId, handRaiseStatus);
  return { roomId, hostUserId: room.hostUserId, userId, handRaiseStatus, raised, ...profile };
}

async function getParticipants(roomId) {
  const [rows] = await db.query(
    `SELECT rp.ParticipantId AS participantId, rp.RoomId AS roomId, rp.UserId AS userId,
            rp.MicStatus AS micStatus, rp.HandRaiseStatus AS handRaiseStatus,
            rp.ParticipantStatus AS participantStatus, rp.JoinedAt AS joinedAt,
            CASE WHEN r.HostUserId = rp.UserId
                 THEN u.FullName
                 ELSE COALESCE(ap.DisplayName, CONCAT('Learner ', RIGHT(rp.UserId, 4)))
            END AS displayName,
            CASE WHEN r.HostUserId = rp.UserId THEN u.FullName ELSE NULL END AS fullName,
            ap.AvatarUrl AS avatarUrl
       FROM RoomParticipants rp
       INNER JOIN Rooms r ON r.RoomId = rp.RoomId
       INNER JOIN Users u ON u.UserId = rp.UserId
       LEFT JOIN AvatarPersonas ap ON ap.UserId = rp.UserId
      WHERE rp.RoomId = ? AND rp.ParticipantStatus = 'JOINED'
      ORDER BY rp.JoinedAt ASC`,
    [roomId],
  );
  return rows;
}

async function getJoinableRoom(roomId) {
  const room = await getRoom(roomId);
  if (!['OPEN', 'LIVE', 'STUDYING', 'SCHEDULED'].includes(String(room.roomStatus).toUpperCase())) {
    const error = new Error('Room is not open for realtime join');
    error.statusCode = 409;
    throw error;
  }
  return room;
}

async function upsertParticipant(roomId, userId, state) {
  const [existing] = await db.query(
    `SELECT ParticipantId AS participantId
       FROM RoomParticipants
      WHERE RoomId = ? AND UserId = ? AND ParticipantStatus = 'JOINED'
      LIMIT 1`,
    [roomId, userId],
  );

  if (existing.length) {
    await db.query(
      `UPDATE RoomParticipants
          SET LastSeenAt = NOW(), MicStatus = ?, HandRaiseStatus = ?
        WHERE ParticipantId = ?`,
      [state.micStatus, state.handRaiseStatus, existing[0].participantId],
    );
    return { participantId: existing[0].participantId, ...state };
  }

  const participantId = `RP_${crypto.randomUUID()}`;
  await db.query(
    `INSERT INTO RoomParticipants
      (ParticipantId, RoomId, UserId, MicStatus, HandRaiseStatus, ParticipantStatus, JoinedAt, LastSeenAt)
     VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())`,
    [participantId, roomId, userId, state.micStatus, state.handRaiseStatus, state.participantStatus],
  );
  return { participantId, ...state };
}

async function ensureActiveParticipant(roomId, userId) {
  const [rows] = await db.query(
    `SELECT ParticipantId FROM RoomParticipants WHERE RoomId = ? AND UserId = ? AND ParticipantStatus = 'JOINED' LIMIT 1`,
    [roomId, userId],
  );
  if (!rows.length) {
    const error = new Error('User has not joined this room');
    error.statusCode = 409;
    throw error;
  }
}

async function getParticipantProfile(userId, hostUserId) {
  const [rows] = await db.query(
    `SELECT u.UserId AS userId, u.FullName AS fullName, ap.DisplayName AS personaDisplayName, ap.AvatarUrl AS avatarUrl
       FROM Users u
       LEFT JOIN AvatarPersonas ap ON ap.UserId = u.UserId
      WHERE u.UserId = ?
      LIMIT 1`,
    [userId],
  );
  if (!rows.length) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }
  const user = rows[0];
  const isHost = String(userId) === String(hostUserId);
  return {
    fullName: isHost ? user.fullName : null,
    displayName: isHost ? user.fullName : user.personaDisplayName || `Learner ${String(userId).slice(-4)}`,
    avatarUrl: user.avatarUrl,
    isHost,
  };
}

function requireUserId(payload = {}) {
  if (!payload.userId) {
    const error = new Error('userId is required');
    error.statusCode = 400;
    throw error;
  }
  return String(payload.userId);
}

module.exports = {
  createRoom,
  getRoom,
  joinRoom,
  leaveRoom,
  setMicState,
  setHandRaiseState,
  getParticipants,
};
