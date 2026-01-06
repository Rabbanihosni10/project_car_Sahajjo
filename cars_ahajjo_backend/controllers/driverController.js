const User = require('../models/user');
const DriverLocation = require('../models/driverLocation');
const Ride = require('../models/ride');

/**
 * Get all drivers for a car owner
 * GET /api/drivers/owner
 */
exports.getOwnerDrivers = async (req, res) => {
  try {
    const ownerId = req.user.id;

    // Assuming drivers have an ownerId or are assigned via a relationship
    // This fetches all drivers (filter by ownerId if stored in driver model)
    const drivers = await User.find({
      role: 'driver',
      // If drivers track their owner, add: ownerId: ownerId
    })
      .select(
        'name email phone licenseNumber vehicleType status rating totalRides totalEarnings'
      )
      .lean();

    // Enhance with stats
    const enhancedDrivers = await Promise.all(
      drivers.map(async (driver) => {
        const stats = await getRideStats(driver._id);
        return {
          ...driver,
          totalRides: stats.totalRides,
          totalEarnings: stats.totalEarnings,
          rating: stats.rating,
        };
      })
    );

    res.status(200).json({
      success: true,
      data: enhancedDrivers,
    });
  } catch (error) {
    console.error('Error fetching drivers:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching drivers',
      error: error.message,
    });
  }
};

/**
 * Get driver details
 * GET /api/drivers/:driverId
 */
exports.getDriverDetails = async (req, res) => {
  try {
    const { driverId } = req.params;

    const driver = await User.findById(driverId).select(
      'name email phone licenseNumber vehicleType yearsOfExperience status isVerified'
    );

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found',
      });
    }

    // Get stats
    const stats = await getRideStats(driverId);

    res.status(200).json({
      success: true,
      data: {
        ...driver.toObject(),
        ...stats,
      },
    });
  } catch (error) {
    console.error('Error fetching driver details:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching driver details',
      error: error.message,
    });
  }
};

/**
 * Get driver statistics
 * GET /api/drivers/:driverId/stats
 */
exports.getDriverStats = async (req, res) => {
  try {
    const { driverId } = req.params;

    const stats = await getRideStats(driverId);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error('Error fetching driver stats:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching driver stats',
      error: error.message,
    });
  }
};

/**
 * Helper: Get ride stats for a driver
 */
async function getRideStats(driverId) {
  try {
    const rides = await Ride.find({ driverId, status: 'completed' }).lean();

    const totalRides = rides.length;
    const totalEarnings = rides.reduce((sum, ride) => sum + (ride.fare || 0), 0);

    // Calculate rating from ratings collection if available
    const Rating = require('../models/rating');
    const ratings = await Rating.find({
      ratedUserId: driverId,
    }).lean();
    const rating =
      ratings.length > 0
        ? (
            ratings.reduce((sum, r) => sum + (r.rating || 0), 0) /
            ratings.length
          ).toFixed(1)
        : 4.5;

    return {
      totalRides,
      totalEarnings: parseFloat(totalEarnings.toFixed(2)),
      rating: parseFloat(rating),
    };
  } catch (error) {
    console.error('Error calculating ride stats:', error);
    return {
      totalRides: 0,
      totalEarnings: 0,
      rating: 0,
    };
  }
}
