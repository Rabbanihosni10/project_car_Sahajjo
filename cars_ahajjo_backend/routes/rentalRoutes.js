const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const rentalController = require('../controllers/rentalController');

const router = express.Router();

// Owner: Create rental listing
router.post('/', authenticateToken, rentalController.createRentalListing);

// Get available rentals
router.get('/', rentalController.getAvailableRentals);
// Search rentals (must be before /:rentalId)
router.get('/search', rentalController.searchRentals);


// Get rental details
router.get('/:rentalId', rentalController.getRentalDetails);

// Calculate rental cost
router.post('/calculate-cost', rentalController.calculateRentalCost);

// Create booking
router.post('/bookings/create', authenticateToken, rentalController.createBooking);

// Get my bookings (renter)
router.get('/user/my-bookings', authenticateToken, rentalController.getMyBookings);

// Owner: Get rental bookings
router.get('/owner/bookings', authenticateToken, rentalController.getRentalBookings);

// Confirm booking (owner)
router.patch('/bookings/:bookingId/confirm', authenticateToken, rentalController.confirmBooking);

// Cancel booking
router.patch('/bookings/:bookingId/cancel', authenticateToken, rentalController.cancelBooking);

// Complete booking
router.patch('/bookings/:bookingId/complete', authenticateToken, rentalController.completeBooking);

module.exports = router;
