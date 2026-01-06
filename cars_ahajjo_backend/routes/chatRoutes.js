const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/auth");
const chatController = require("../controllers/chatController");

/**
 * @route   POST /api/chat/ask
 * @desc    Ask AI Assistant a question
 * @access  Private
 */
const multer = require("multer");
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

/**
 * @route   POST /api/chat/ask
 * @desc    Ask AI Assistant a question (supports image upload)
 * @access  Private
 */
router.post("/ask", authenticateToken, upload.single("image"), chatController.askAI);

/**
 * @route   GET /api/chat/history
 * @desc    Get chat history for current user
 * @access  Private
 */
router.get("/history", authenticateToken, chatController.getChatHistory);

/**
 * @route   DELETE /api/chat/history
 * @desc    Clear chat history for current user
 * @access  Private
 */
router.delete("/history", authenticateToken, chatController.clearChatHistory);

module.exports = router;
