const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const {
	listGarages,
	nearbyGarages,
	seedGarages,
	createGarage,
	getGarageById,
	updateGarage,
	deleteGarage,
	getOwnerGarages,
} = require('../controllers/garageController');

const router = express.Router();

router.get('/', listGarages);
router.get('/nearby', nearbyGarages);
router.get('/owner/my-garages', authenticateToken, getOwnerGarages);
router.post('/seed', seedGarages);

// CRUD endpoints used by the app
router.post('/create', authenticateToken, createGarage);
router.get('/:id', getGarageById);
router.put('/:id', authenticateToken, updateGarage);
router.delete('/:id', authenticateToken, deleteGarage);

module.exports = router;
