const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Get all conversations
router.get('/conversations', messageController.getConversations);

// Get or create conversation with a user
router.post('/conversations/get-or-create', messageController.getOrCreateConversation);

// Get chat history between two users
router.get('/chat-history/:otherUserId', messageController.getChatHistory);

// Send a message
router.post('/send', messageController.sendMessage);

// Delete a message
router.delete('/delete/:messageId', messageController.deleteMessage);

// Mark messages as read
router.post('/mark-as-read', messageController.markAsRead);

module.exports = router;
