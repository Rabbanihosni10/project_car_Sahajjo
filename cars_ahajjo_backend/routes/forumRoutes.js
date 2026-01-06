const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const forumController = require('../controllers/forumController');

const router = express.Router();

// ===== POST ROUTES =====
router.post('/posts', authenticateToken, forumController.createPost);
router.get('/posts', forumController.getPosts);
router.get('/posts/:postId', forumController.getPostDetails);
router.patch('/posts/:postId', authenticateToken, forumController.updatePost);
router.delete('/posts/:postId', authenticateToken, forumController.deletePost);
router.post('/posts/:postId/like', authenticateToken, forumController.likePost);

// ===== COMMENT ROUTES =====
router.post('/posts/:postId/comments', authenticateToken, forumController.addComment);
router.post('/comments/:commentId/like', authenticateToken, forumController.likeComment);

module.exports = router;
