const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const notificationController = require('../controllers/notificationController');

const router = express.Router();

// Register device token
router.post('/register-token', authenticateToken, notificationController.registerToken);

// Unregister device token
router.post('/unregister-token', notificationController.unregisterToken);

// Send notification
router.post('/send', authenticateToken, notificationController.sendNotification);

// Get notifications
router.get('/', authenticateToken, notificationController.getNotifications);

// Mark as read
router.patch('/:notificationId/read', authenticateToken, notificationController.markAsRead);

// Mark all as read
router.patch('/read/all', authenticateToken, notificationController.markAllAsRead);

// Delete notification
router.delete('/:notificationId', authenticateToken, notificationController.deleteNotification);

module.exports = router;
