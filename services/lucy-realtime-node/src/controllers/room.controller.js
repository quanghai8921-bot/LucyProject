const roomService = require('../services/room.service');
const socketStateService = require('../services/socket-state.service');
const { successResponse } = require('../utils/response');

async function createRoom(req, res, next) {
  try {
    const room = await roomService.createRoom(req.body);
    res.status(201).json(successResponse(room));
  } catch (error) {
    next(error);
  }
}

async function getRoom(req, res, next) {
  try {
    const room = await roomService.getRoom(req.params.roomId);
    res.json(successResponse(room));
  } catch (error) {
    next(error);
  }
}

async function joinRoom(req, res, next) {
  try {
    const result = await roomService.joinRoom(req.params.roomId, req.body);
    res.json(successResponse(result));
  } catch (error) {
    next(error);
  }
}

async function leaveRoom(req, res, next) {
  try {
    const result = await roomService.leaveRoom(req.params.roomId, req.body);
    res.json(successResponse(result));
  } catch (error) {
    next(error);
  }
}

async function getRoomState(req, res, next) {
  try {
    const state = socketStateService.getRoomState(req.params.roomId);
    res.json(successResponse(state));
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createRoom,
  getRoom,
  joinRoom,
  leaveRoom,
  getRoomState,
};
