const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const { updateMyLocation, getMyLocation, getDriverLocation } = require('../controllers/locationController');

const router = express.Router();

router.post('/update', authenticateToken, updateMyLocation);
router.post('/', authenticateToken, updateMyLocation);
router.get('/me', authenticateToken, getMyLocation);
router.get('/driver/:id', getDriverLocation);

module.exports = router;
