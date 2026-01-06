const Ride = require('../models/ride');
const User = require('../models/user');
const Transaction = require('../models/transaction');

// Request a ride
exports.requestRide = async (req, res) => {
  try {
    const {
      pickupLocation,
      dropLocation,
      distance,
      duration,
      notes,
    } = req.body;
    const riderId = req.user.id;

    if (!pickupLocation || !dropLocation) {
      return res.status(400).json({
        success: false,
        message: 'Pickup and drop locations are required',
      });
    }

    // Calculate fare
    const baseFare = 50;
    const ratePerKm = 15;
    const ratePerMin = 2;
    const distanceFare = distance * ratePerKm;
    const timeFare = duration * ratePerMin;
    const subtotal = baseFare + distanceFare + timeFare;
    const tax = subtotal * 0.05; // 5% tax
    const totalFare = subtotal + tax;

    const ride = new Ride({
      riderId,
      pickupLocation,
      dropLocation,
      distance,
      duration,
      baseFare,
      distanceFare,
      timeFare,
      tax,
      totalFare,
      notes,
      requestedAt: new Date(),
    });

    await ride.save();

    // Emit ride request via Socket.io
    req.io.emit('ride_request', {
      rideId: ride._id,
      riderId,
      pickupLocation,
      dropLocation,
      totalFare,
      distance,
    });

    res.status(201).json({
      success: true,
      message: 'Ride requested',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error requesting ride',
      error: error.message,
    });
  }
};

// Accept a ride (driver)
exports.acceptRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const driverId = req.user.id;

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    if (ride.status !== 'requested') {
      return res.status(400).json({
        success: false,
        message: 'Ride is no longer available',
      });
    }

    ride.driverId = driverId;
    ride.status = 'accepted';
    ride.acceptedAt = new Date();
    await ride.save();

    // Notify rider
    req.io.emit('ride_accepted', {
      rideId: ride._id,
      driverId,
      totalFare: ride.totalFare,
    });

    res.status(200).json({
      success: true,
      message: 'Ride accepted',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error accepting ride',
      error: error.message,
    });
  }
};

// Reject a ride (driver)
exports.rejectRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const { reason } = req.body;

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    ride.status = 'cancelled';
    ride.cancellationReason = reason || 'Driver rejected';
    ride.cancelledAt = new Date();
    await ride.save();

    req.io.emit('ride_rejected', { rideId: ride._id, reason });

    res.status(200).json({
      success: true,
      message: 'Ride rejected',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error rejecting ride',
      error: error.message,
    });
  }
};

// Start ride (driver)
exports.startRide = async (req, res) => {
  try {
    const { rideId } = req.params;

    const ride = await Ride.findById(rideId);
    if (!ride || ride.status !== 'accepted') {
      return res.status(400).json({
        success: false,
        message: 'Ride cannot be started',
      });
    }

    ride.status = 'in_progress';
    ride.startedAt = new Date();
    await ride.save();

    req.io.emit('ride_started', { rideId: ride._id });

    res.status(200).json({
      success: true,
      message: 'Ride started',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error starting ride',
      error: error.message,
    });
  }
};

// Complete ride (driver)
exports.completeRide = async (req, res) => {
  try {
    const { rideId } = req.params;

    const ride = await Ride.findById(rideId);
    if (!ride || ride.status !== 'in_progress') {
      return res.status(400).json({
        success: false,
        message: 'Ride cannot be completed',
      });
    }

    ride.status = 'completed';
    ride.completedAt = new Date();
    ride.paymentStatus = 'pending';
    await ride.save();

    req.io.emit('ride_completed', { rideId: ride._id, totalFare: ride.totalFare });

    res.status(200).json({
      success: true,
      message: 'Ride completed',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error completing ride',
      error: error.message,
    });
  }
};

// Cancel ride
exports.cancelRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const { reason } = req.body;

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    if (!['requested', 'accepted'].includes(ride.status)) {
      return res.status(400).json({
        success: false,
        message: 'Ride cannot be cancelled at this stage',
      });
    }

    ride.status = 'cancelled';
    ride.cancellationReason = reason;
    ride.cancelledAt = new Date();
    await ride.save();

    req.io.emit('ride_cancelled', { rideId: ride._id, reason });

    res.status(200).json({
      success: true,
      message: 'Ride cancelled',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error cancelling ride',
      error: error.message,
    });
  }
};

// Get ride details
exports.getRide = async (req, res) => {
  try {
    const { rideId } = req.params;

    const ride = await Ride.findById(rideId)
      .populate('riderId', 'name phone email avatar')
      .populate('driverId', 'name phone email avatar');

    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    res.status(200).json({ success: true, data: ride });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching ride',
      error: error.message,
    });
  }
};

// Get user's rides (rider or driver)
exports.getUserRides = async (req, res) => {
  try {
    const userId = req.user.id;
    const { role = 'rider', status } = req.query;

    const query = role === 'driver' ? { driverId: userId } : { riderId: userId };
    if (status) query.status = status;

    const rides = await Ride.find(query)
      .populate('riderId', 'name phone avatar')
      .populate('driverId', 'name phone avatar')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, data: rides });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching rides',
      error: error.message,
    });
  }
};

// Rate a ride
exports.rateRide = async (req, res) => {
  try {
    const { rideId } = req.params;
    const { rating, feedback } = req.body;
    const userId = req.user.id;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5',
      });
    }

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    if (ride.status !== 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Only completed rides can be rated',
      });
    }

    if (userId.toString() === ride.riderId.toString()) {
      ride.driverRating = { rating, feedback, ratedBy: 'rider' };
    } else if (userId.toString() === ride.driverId.toString()) {
      ride.riderRating = { rating, feedback, ratedBy: 'driver' };
    } else {
      return res.status(403).json({
        success: false,
        message: 'You cannot rate this ride',
      });
    }

    await ride.save();

    res.status(200).json({
      success: true,
      message: 'Ride rated',
      data: ride,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error rating ride',
      error: error.message,
    });
  }
};
