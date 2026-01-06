const CarRental = require('../models/carRental');
const RentalBooking = require('../models/rentalBooking');

// Owner: Create car rental listing
exports.createRentalListing = async (req, res) => {
  try {
    const {
      carName,
      carModel,
      registrationNumber,
      category,
      location,
      pricePerDay,
      pricePerMonth,
      capacity,
      features,
      deposit,
      insurance,
      cancellationPolicy,
      documents,
    } = req.body;

    const rental = new CarRental({
      ownerId: req.user.id,
      carName,
      carModel,
      registrationNumber,
      category,
      location,
      pricePerDay,
      pricePerMonth,
      capacity,
      features,
      deposit,
      insurance,
      cancellationPolicy,
      documents,
      availability: {
        startDate: new Date(),
        endDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      },
    });

    await rental.save();

    res.status(201).json({
      success: true,
      message: 'Car rental listing created',
      data: rental,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating rental listing',
      error: error.message,
    });
  }
};

// Get all available rentals
exports.getAvailableRentals = async (req, res) => {
  try {
    const { category, location, priceMin, priceMax, pickupDate, returnDate } = req.query;

    const query = { status: 'active' };

    if (category) query.category = category;
    if (location) query.location = new RegExp(location, 'i');
    if (priceMin || priceMax) {
      query.pricePerDay = {};
      if (priceMin) query.pricePerDay.$gte = parseFloat(priceMin);
      if (priceMax) query.pricePerDay.$lte = parseFloat(priceMax);
    }

    let rentals = await CarRental.find(query)
      .populate('ownerId', 'name email phone')
      .sort({ 'ratings.average': -1 });

    // Add default image if not present
    rentals = rentals.map(rental => {
      const rentalObj = rental.toObject();
      if (!rentalObj.image) {
        rentalObj.image = `https://via.placeholder.com/200x150?text=${encodeURIComponent(rentalObj.carName || 'Car')}`;
      }
      return rentalObj;
    });

    // Filter by availability if dates provided
    if (pickupDate && returnDate) {
      const pickup = new Date(pickupDate);
      const returnD = new Date(returnDate);

      rentals = rentals.filter((rental) => {
        const available =
          rental.availability.startDate <= pickup &&
          rental.availability.endDate >= returnD;
        return available;
      });
    }

    res.status(200).json({
      success: true,
      data: rentals,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching rentals',
      error: error.message,
    });
  }
};

// Search rentals
exports.searchRentals = async (req, res) => {
  try {
    const { q } = req.query;

    if (!q) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required',
      });
    }

    const searchRegex = new RegExp(q, 'i');

    let rentals = await CarRental.find({
      $or: [
        { carName: searchRegex },
        { carModel: searchRegex },
        { category: searchRegex },
        { location: searchRegex },
      ],
      status: 'active',
    })
      .populate('ownerId', 'name email phone')
      .sort({ 'ratings.average': -1 })
      .limit(50);

    // Add default image if not present
    rentals = rentals.map(rental => {
      const rentalObj = rental.toObject();
      if (!rentalObj.image) {
        rentalObj.image = `https://via.placeholder.com/200x150?text=${encodeURIComponent(rentalObj.carName || 'Car')}`;
      }
      return rentalObj;
    });

    res.status(200).json({
      success: true,
      data: rentals,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error searching rentals',
      error: error.message,
    });
  }
};

// Get rental details
exports.getRentalDetails = async (req, res) => {
  try {
    const { rentalId } = req.params;

    const rental = await CarRental.findById(rentalId).populate('ownerId', 'name email phone rating');

    if (!rental) {
      return res.status(404).json({ success: false, message: 'Rental not found' });
    }

    res.status(200).json({ success: true, data: rental });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching rental',
      error: error.message,
    });
  }
};

// Calculate rental cost
exports.calculateRentalCost = async (req, res) => {
  try {
    const { rentalId, pickupDate, returnDate, insurance, additionalServices } = req.body;

    const rental = await CarRental.findById(rentalId);
    if (!rental) {
      return res.status(404).json({ success: false, message: 'Rental not found' });
    }

    const pickup = new Date(pickupDate);
    const returnD = new Date(returnDate);
    const days = Math.ceil((returnD - pickup) / (1000 * 60 * 60 * 24));
    const months = Math.floor(days / 30);
    const remainingDays = days % 30;

    let totalCost = 0;

    // Calculate rental cost (prefer monthly rate for longer rentals)
    if (months > 0) {
      totalCost += months * rental.pricePerMonth;
      totalCost += remainingDays * rental.pricePerDay;
    } else {
      totalCost += days * rental.pricePerDay;
    }

    let insuranceCost = 0;
    if (insurance && rental.insurance.included) {
      insuranceCost = days * 500; // Example: 500/day
      totalCost += insuranceCost;
    }

    let additionalCost = 0;
    if (additionalServices) {
      additionalServices.forEach((service) => {
        additionalCost += service.cost;
      });
      totalCost += additionalCost;
    }

    const breakdown = {
      rentalDays: days,
      dailyRate: rental.pricePerDay,
      monthlyRate: rental.pricePerMonth,
      rentalCost: months > 0 ? months * rental.pricePerMonth + remainingDays * rental.pricePerDay : days * rental.pricePerDay,
      insurance: insuranceCost,
      additional: additionalCost,
      deposit: rental.deposit?.amount || 0,
      total: Math.round(totalCost * 100) / 100,
    };

    res.status(200).json({
      success: true,
      data: breakdown,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error calculating cost',
      error: error.message,
    });
  }
};

// Create booking
exports.createBooking = async (req, res) => {
  try {
    const {
      rentalId,
      pickupDate,
      returnDate,
      pickupLocation,
      returnLocation,
      insurance,
      additionalCharges,
      totalAmount,
      paymentMethod,
    } = req.body;
    const renterId = req.user.id;

    const rental = await CarRental.findById(rentalId);
    if (!rental) {
      return res.status(404).json({ success: false, message: 'Rental not found' });
    }

    const pickup = new Date(pickupDate);
    const returnD = new Date(returnDate);
    const numberOfDays = Math.ceil((returnD - pickup) / (1000 * 60 * 60 * 24));

    const booking = new RentalBooking({
      rentalId,
      renterId,
      ownerId: rental.ownerId,
      pickupDate: pickup,
      returnDate: returnD,
      pickupLocation: pickupLocation || rental.location,
      returnLocation: returnLocation || rental.location,
      numberOfDays,
      dailyRate: rental.pricePerDay,
      monthlyRate: rental.pricePerMonth,
      totalRentalCost: totalAmount,
      deposit: {
        amount: rental.deposit?.amount,
        status: 'pending',
      },
      insurance: insurance
        ? {
            selected: true,
            type: rental.insurance?.type,
            cost: numberOfDays * 500,
          }
        : { selected: false },
      additionalCharges: additionalCharges || {},
      payment: {
        totalAmount,
        method: paymentMethod || 'cash',
        status: paymentMethod === 'cash' ? 'pending' : 'completed',
      },
      status: 'pending',
    });

    await booking.save();

    // Emit socket event
    req.io.emit('booking_created', {
      bookingId: booking._id,
      rentalId,
      ownerMessage: `New rental booking for ${rental.carName}`,
    });

    res.status(201).json({
      success: true,
      message: 'Booking created',
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating booking',
      error: error.message,
    });
  }
};

// Get my bookings (renter)
exports.getMyBookings = async (req, res) => {
  try {
    const renterId = req.user.id;

    const bookings = await RentalBooking.find({ renterId })
      .populate('rentalId', 'carName carModel category location')
      .populate('ownerId', 'name email phone')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching bookings',
      error: error.message,
    });
  }
};

// Owner: Get rental bookings
exports.getRentalBookings = async (req, res) => {
  try {
    const ownerId = req.user.id;

    const bookings = await RentalBooking.find({ ownerId })
      .populate('rentalId', 'carName carModel category location')
      .populate('renterId', 'name email phone')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching bookings',
      error: error.message,
    });
  }
};

// Confirm booking (owner)
exports.confirmBooking = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const ownerId = req.user.id;

    const booking = await RentalBooking.findById(bookingId);
    if (!booking || booking.ownerId.toString() !== ownerId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    booking.status = 'confirmed';
    await booking.save();

    req.io.emit('booking_confirmed', {
      bookingId,
      renterMessage: 'Your rental booking is confirmed',
    });

    res.status(200).json({
      success: true,
      message: 'Booking confirmed',
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error confirming booking',
      error: error.message,
    });
  }
};

// Cancel booking
exports.cancelBooking = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { reason } = req.body;

    const booking = await RentalBooking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    booking.status = 'cancelled';
    booking.cancellation = {
      requestedAt: new Date(),
      cancelledAt: new Date(),
      reason,
      refundAmount: booking.payment.totalAmount * 0.8, // 80% refund
    };

    await booking.save();

    res.status(200).json({
      success: true,
      message: 'Booking cancelled',
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error cancelling booking',
      error: error.message,
    });
  }
};

// Complete booking
exports.completeBooking = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { mileageAtReturn, damageReport, renterRating, renterReview } = req.body;

    const booking = await RentalBooking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    booking.status = 'completed';
    booking.mileage.atReturn = mileageAtReturn;
    booking.carCondition.afterReturn = {
      recordedAt: new Date(),
      damageReport,
    };
    booking.feedback = {
      renterRating,
      renterReview,
    };

    await booking.save();

    res.status(200).json({
      success: true,
      message: 'Booking completed',
      data: booking,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error completing booking',
      error: error.message,
    });
  }
};
