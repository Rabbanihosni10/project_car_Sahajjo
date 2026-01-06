const express = require('express');
const mapController = require('../controllers/mapController');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All map routes require authentication
router.use(authenticateToken);

// Get user's current location
router.get('/my-location', mapController.getMyLocation);

// Get nearby garages
router.get('/nearby-garages', mapController.getNearbyGarages);

// Get driver locations (for owner view)
router.get('/driver-locations', mapController.getDriverLocations);

// Get traffic info
router.get('/traffic', mapController.getTrafficInfo);

// Get route directions
router.post('/route-directions', mapController.getRouteDirections);

// Seed driver locations (for testing)
router.post('/seed-drivers', mapController.seedDriverLocations);

// User-contributed places
router.post('/places', mapController.addPlace);
router.get('/places', mapController.getPlaces);
router.delete('/places/:id', mapController.deletePlace);

module.exports = router;
