const axios = require('axios');

const client = axios.create({
  baseURL: process.env.JAVA_LMS_BASE_URL || 'http://localhost:8080',
  timeout: 10000,
});

async function createRoom(payload) {
  return {
    id: payload.roomId,
    ...payload,
  };
}

async function getRoom(roomId) {
  return {
    id: roomId,
    source: 'java-lms',
  };
}

module.exports = {
  client,
  createRoom,
  getRoom,
};
