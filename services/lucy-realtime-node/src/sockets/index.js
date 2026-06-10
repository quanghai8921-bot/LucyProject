const { Server } = require('socket.io');

const registerRoomSocket = require('./room.socket');
const registerChatSocket = require('./chat.socket');
const registerMicSocket = require('./mic.socket');
const registerAttendanceSocket = require('./attendance.socket');
const registerHandSocket = require('./hand.socket');
const registerSlideSocket = require('./slide.socket');

function registerSockets(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: 'https://lucyproject.vercel.app',
      methods: ['GET', 'POST'],
    },
  });

  io.on('connection', (socket) => {
    registerRoomSocket(io, socket);
    registerChatSocket(io, socket);
    registerMicSocket(io, socket);
    registerAttendanceSocket(io, socket);
    registerHandSocket(io, socket);
    registerSlideSocket(io, socket);
  });

  return io;
}

module.exports = registerSockets;
