const express = require('express');

const roomController = require('../controllers/room.controller');
const paymentNotificationController = require('../controllers/payment-notification.controller');

const router = express.Router();

router.get('/rooms/:roomId/state', roomController.getRoomState);
router.post('/payment-notifications', paymentNotificationController.broadcastPaymentNotification);

module.exports = router;
