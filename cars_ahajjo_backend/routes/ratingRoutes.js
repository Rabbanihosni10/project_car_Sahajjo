const express = require('express');
const router = express.Router();
const ratingController = require('../controllers/ratingController');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Submit a rating
router.post('/submit', ratingController.submitRating);

// Get ratings for a user
router.get('/user/:userId', ratingController.getUserRatings);

// Get rating summary
router.get('/summary/:userId', ratingController.getRatingSummary);

// Update a rating
router.put('/:ratingId', ratingController.updateRating);

// Delete a rating
router.delete('/:ratingId', ratingController.deleteRating);

module.exports = router;
