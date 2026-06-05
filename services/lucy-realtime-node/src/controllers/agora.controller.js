const agoraService = require('../services/agora.service');
const { successResponse } = require('../utils/response');

async function createToken(req, res, next) {
  try {
    const token = await agoraService.createRtcToken(req.body);
    res.json(successResponse(token));
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createToken,
};
