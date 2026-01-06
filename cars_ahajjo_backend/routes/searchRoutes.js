const express = require('express');
const router = express.Router();
const searchController = require('../controllers/searchController');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Search drivers
router.get('/drivers', searchController.searchDrivers);

// Filter drivers
router.get('/drivers/filter', searchController.filterDrivers);

// Search owners
router.get('/owners', searchController.searchOwners);

// Search garages
router.get('/garages', searchController.searchGarages);

// Filter garages
router.get('/garages/filter', searchController.filterGarages);

module.exports = router;
