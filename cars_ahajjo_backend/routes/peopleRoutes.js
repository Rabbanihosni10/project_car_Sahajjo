const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const {
  discoverPeople,
  getUserProfile,
  sendConnectionRequest,
  acceptConnectionRequest,
  rejectConnectionRequest,
  toggleFollow,
  getFriends,
  getFollowers,
  getFollowing,
  getPendingRequests,
  blockUser,
  unblockUser,
  getChatList,
  getMyConnections,
  updateProfile,
} = require('../controllers/peopleController');

// Public routes
router.get('/discover', authenticateToken, discoverPeople);
router.get('/profile/:userId', authenticateToken, getUserProfile);
router.get('/friends/:userId', authenticateToken, getFriends);
router.get('/followers/:userId', authenticateToken, getFollowers);
router.get('/following/:userId', authenticateToken, getFollowing);

// Protected routes - User actions
router.post('/connect', authenticateToken, sendConnectionRequest);
router.post('/accept-connection', authenticateToken, acceptConnectionRequest);
router.post('/reject-connection', authenticateToken, rejectConnectionRequest);
router.post('/follow', authenticateToken, toggleFollow);
router.post('/block', authenticateToken, blockUser);
router.post('/unblock', authenticateToken, unblockUser);

// Profile management
router.get('/pending-requests', authenticateToken, getPendingRequests);
router.get('/chat-list', authenticateToken, getChatList);
router.get('/my-connections', authenticateToken, getMyConnections);
router.put('/profile', authenticateToken, updateProfile);

module.exports = router;
