const express = require('express');
const router = express.Router();

const { authenticateToken } = require('../middleware/auth');
const jobController = require('../controllers/jobController');

/**
 * OWNER ROUTES
 */

// Create job post
router.post('/', authenticateToken, jobController.createJobPost);

// Close job post
router.patch('/:jobId/close', authenticateToken, jobController.closeJobPost);

// Update application status
router.patch(
  '/:jobId/applicants/:driverId',
  authenticateToken,
  jobController.updateApplicationStatus
);

/**
 * DRIVER ROUTES
 */

// Apply for a job
router.post('/:jobId/apply', authenticateToken, jobController.applyForJob);

// Get driver's applications (IMPORTANT: placed before :jobId)
router.get(
  '/driver/my-applications',
  authenticateToken,
  jobController.getApplications
);

/**
 * PUBLIC ROUTES
 */

// Get all job posts
router.get('/', jobController.getJobPosts);

// Get job post details (KEEP THIS LAST)
router.get('/:jobId', jobController.getJobPost);

module.exports = router;
