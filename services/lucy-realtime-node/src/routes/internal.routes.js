const express = require('express');

const roomController = require('../controllers/room.controller');

const router = express.Router();

router.get('/rooms/:roomId/state', roomController.getRoomState);

module.exports = router;
