const agoraService = require('../services/agora.service');
const { successResponse } = require('../utils/response');

async function startRecording(req, res, next) {
  try {
    const recording = await agoraService.startRecording(req.params.roomId, req.body);
    res.json(successResponse(recording));
  } catch (error) {
    next(error);
  }
}

async function stopRecording(req, res, next) {
  try {
    const recording = await agoraService.stopRecording(req.params.roomId, req.body);
    res.json(successResponse(recording));
  } catch (error) {
    next(error);
  }
}

module.exports = {
  startRecording,
  stopRecording,
};
