const express = require('express');

const agoraController = require('../controllers/agora.controller');
const roomController = require('../controllers/room.controller');
const recordingController = require('../controllers/recording.controller');

const router = express.Router();

router.post('/agora/token', agoraController.createToken);
router.post('/rooms', roomController.createRoom);
router.get('/rooms/:roomId', roomController.getRoom);
router.post('/rooms/:roomId/join', roomController.joinRoom);
router.post('/rooms/:roomId/leave', roomController.leaveRoom);
router.get('/rooms/:roomId/state', roomController.getRoomState);
router.post('/rooms/:roomId/recordings/start', recordingController.startRecording);
router.post('/rooms/:roomId/recordings/stop', recordingController.stopRecording);

module.exports = router;
