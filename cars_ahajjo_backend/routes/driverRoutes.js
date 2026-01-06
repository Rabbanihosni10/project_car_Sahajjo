const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driverController');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

/**
 * @route   GET /api/drivers/owner
 * @desc    Get all drivers for current owner
 * @access  Private (Owner)
 */
router.get('/owner', driverController.getOwnerDrivers);

/**
 * @route   GET /api/drivers/:driverId
 * @desc    Get driver details
 * @access  Private
 */
router.get('/:driverId', driverController.getDriverDetails);

/**
 * @route   GET /api/drivers/:driverId/stats
 * @desc    Get driver statistics
 * @access  Private
 */
router.get('/:driverId/stats', driverController.getDriverStats);

module.exports = router;
