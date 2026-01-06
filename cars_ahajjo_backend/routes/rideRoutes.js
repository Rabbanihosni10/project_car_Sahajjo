const express = require('express');
const router = express.Router();
const rideController = require('../controllers/rideController');
const { authenticateToken } = require('../middleware/auth');

router.use(authenticateToken);

// Request a ride
router.post('/', rideController.requestRide);

// Accept a ride (driver)
router.post('/:rideId/accept', rideController.acceptRide);

// Reject a ride (driver)
router.post('/:rideId/reject', rideController.rejectRide);

// Start ride (driver)
router.post('/:rideId/start', rideController.startRide);

// Complete ride (driver)
router.post('/:rideId/complete', rideController.completeRide);

// Cancel a ride
router.post('/:rideId/cancel', rideController.cancelRide);

// Get ride details
router.get('/:rideId', rideController.getRide);

// Get user's rides
router.get('/', rideController.getUserRides);

// Rate a ride
router.post('/:rideId/rate', rideController.rateRide);

module.exports = router;
