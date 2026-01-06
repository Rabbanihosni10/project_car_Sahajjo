const Fare = require('../models/fare');
const Ride = require('../models/ride');

// Fare calculation config
const FARE_CONFIG = {
  baseFare: 50, // BDT
  perKm: 15, // BDT/km
  perMinute: 2, // BDT/minute
  taxPercentage: 5, // 5% tax
  minFare: 50, // Minimum fare
};

// Calculate dynamic fare based on demand (surge pricing)
const calculateSurgeFactor = (hour, demandLevel = 'normal') => {
  // Peak hours: 7-9 AM, 12-2 PM, 5-7 PM = 1.5x
  // Night hours: 10 PM - 5 AM = 1.3x
  // Normal = 1.0x

  const peakHours = [7, 8, 12, 13, 17, 18];
  const nightHours = [22, 23, 0, 1, 2, 3, 4];

  if (demandLevel === 'high') return 1.5;
  if (peakHours.includes(hour)) return 1.5;
  if (nightHours.includes(hour)) return 1.3;
  return 1.0;
};

// Calculate fare
const calculateFare = (distance, durationMinutes, surgeFactor = 1.0) => {
  let fare = FARE_CONFIG.baseFare + distance * FARE_CONFIG.perKm + durationMinutes * FARE_CONFIG.perMinute;

  // Apply surge multiplier
  fare *= surgeFactor;

  // Ensure minimum fare
  fare = Math.max(fare, FARE_CONFIG.minFare);

  // Calculate tax
  const tax = Math.round(fare * (FARE_CONFIG.taxPercentage / 100) * 100) / 100;

  // Total
  const total = Math.round((fare + tax) * 100) / 100;

  return {
    baseFare: Math.round(fare * 100) / 100,
    tax,
    surgeMultiplier: surgeFactor,
    total,
    breakdown: {
      baseFare: FARE_CONFIG.baseFare,
      distanceCharge: Math.round(distance * FARE_CONFIG.perKm * 100) / 100,
      timeCharge: Math.round(durationMinutes * FARE_CONFIG.perMinute * 100) / 100,
    },
  };
};

// Get fare estimate
exports.estimateFare = async (req, res) => {
  try {
    const { distance, durationMinutes, demandLevel } = req.body;

    if (!distance || !durationMinutes) {
      return res.status(400).json({
        success: false,
        message: 'Distance and duration are required',
      });
    }

    const currentHour = new Date().getHours();
    const surgeFactor = calculateSurgeFactor(currentHour, demandLevel);
    const fareDetails = calculateFare(distance, durationMinutes, surgeFactor);

    res.status(200).json({
      success: true,
      data: {
        fareEstimate: fareDetails,
        surgeFactor,
        note: surgeFactor > 1.0 ? 'Surge pricing applied' : 'Normal pricing',
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error calculating fare',
      error: error.message,
    });
  }
};

// Save fare record (after ride completion)
exports.recordFare = async (req, res) => {
  try {
    const { rideId, distance, durationMinutes, surgeFactor, paymentMethod } = req.body;

    const ride = await Ride.findById(rideId);
    if (!ride) {
      return res.status(404).json({ success: false, message: 'Ride not found' });
    }

    const fareDetails = calculateFare(distance, durationMinutes, surgeFactor);

    const fare = new Fare({
      rideId,
      riderId: ride.riderId,
      driverId: ride.driverId,
      distance,
      durationMinutes,
      fare: fareDetails.baseFare,
      tax: fareDetails.tax,
      total: fareDetails.total,
      surgeMultiplier: surgeFactor,
      paymentMethod,
      currency: 'BDT',
      status: 'completed',
      recordedAt: new Date(),
    });

    await fare.save();

    // Update ride with fare info
    ride.fareAmount = fareDetails.total;
    ride.fareBreakdown = {
      base: fareDetails.baseFare,
      tax: fareDetails.tax,
      surge: surgeFactor,
    };
    await ride.save();

    res.status(201).json({
      success: true,
      message: 'Fare recorded',
      data: fare,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error recording fare',
      error: error.message,
    });
  }
};

// Get fare history (rider or driver)
exports.getFareHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { role } = req.query; // 'rider' or 'driver'

    const query = role === 'driver' ? { driverId: userId } : { riderId: userId };

    const fares = await Fare.find(query)
      .populate('riderId', 'name email')
      .populate('driverId', 'name email')
      .sort({ recordedAt: -1 });

    res.status(200).json({
      success: true,
      data: fares,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching fare history',
      error: error.message,
    });
  }
};

// Generate invoice/receipt
exports.generateReceipt = async (req, res) => {
  try {
    const { fareId } = req.params;

    const fare = await Fare.findById(fareId)
      .populate('riderId', 'name email phone')
      .populate('driverId', 'name email phone')
      .populate('rideId', 'pickup drop');

    if (!fare) {
      return res.status(404).json({ success: false, message: 'Fare not found' });
    }

    // Generate receipt data
    const receipt = {
      receiptNo: `RECEIPT-${fare._id}`,
      date: fare.recordedAt,
      ride: {
        pickup: fare.rideId?.pickup,
        drop: fare.rideId?.drop,
        distance: fare.distance,
        duration: `${fare.durationMinutes} minutes`,
      },
      rider: {
        name: fare.riderId?.name,
        email: fare.riderId?.email,
        phone: fare.riderId?.phone,
      },
      driver: {
        name: fare.driverId?.name,
        email: fare.driverId?.email,
        phone: fare.driverId?.phone,
      },
      charges: {
        baseFare: fare.fare,
        tax: fare.tax,
        surgeMultiplier: fare.surgeMultiplier,
      },
      total: fare.total,
      paymentMethod: fare.paymentMethod,
      currency: fare.currency,
      status: fare.status,
    };

    res.status(200).json({
      success: true,
      data: receipt,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error generating receipt',
      error: error.message,
    });
  }
};

// Get fare statistics
exports.getFareStatistics = async (req, res) => {
  try {
    const userId = req.user.id;
    const { role, days = 30 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const query = role === 'driver' ? { driverId: userId } : { riderId: userId };
    query.recordedAt = { $gte: startDate };

    const fares = await Fare.find(query);

    const totalEarnings = fares.reduce((sum, f) => sum + f.total, 0);
    const totalRides = fares.length;
    const avgFare = totalRides > 0 ? Math.round((totalEarnings / totalRides) * 100) / 100 : 0;

    res.status(200).json({
      success: true,
      data: {
        totalEarnings: Math.round(totalEarnings * 100) / 100,
        totalRides,
        averageFare: avgFare,
        period: `Last ${days} days`,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching statistics',
      error: error.message,
    });
  }
};
