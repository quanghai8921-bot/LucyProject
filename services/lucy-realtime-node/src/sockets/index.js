const { Server } = require('socket.io');

const registerRoomSocket = require('./room.socket');
const registerChatSocket = require('./chat.socket');
const registerMicSocket = require('./mic.socket');
const registerAttendanceSocket = require('./attendance.socket');

function registerSockets(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  io.on('connection', (socket) => {
    registerRoomSocket(io, socket);
    registerChatSocket(io, socket);
    registerMicSocket(io, socket);
    registerAttendanceSocket(io, socket);
  });

  return io;
}

module.exports = registerSockets;
