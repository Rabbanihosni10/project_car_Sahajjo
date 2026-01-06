const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const fareController = require('../controllers/fareController');

const router = express.Router();

// Estimate fare
router.post('/estimate', fareController.estimateFare);

// Record fare after ride completion
router.post('/record', authenticateToken, fareController.recordFare);

// Get fare history
router.get('/history', authenticateToken, fareController.getFareHistory);

// Get fare statistics
router.get('/statistics', authenticateToken, fareController.getFareStatistics);

// Generate receipt
router.get('/receipt/:fareId', authenticateToken, fareController.generateReceipt);

module.exports = router;
