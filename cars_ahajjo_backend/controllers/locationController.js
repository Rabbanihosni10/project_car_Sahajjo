const DriverLocation = require('../models/driverLocation');

exports.updateMyLocation = async (req, res) => {
  try {
    // Accept both lat/lng and latitude/longitude for compatibility
    const { lat, lng, latitude, longitude } = req.body;
    const finalLat = lat !== undefined ? lat : latitude;
    const finalLng = lng !== undefined ? lng : longitude;
    
    if (typeof finalLat !== 'number' || typeof finalLng !== 'number') {
      return res.status(400).json({ message: 'lat/latitude and lng/longitude must be numbers' });
    }
    const doc = await DriverLocation.findOneAndUpdate(
      { userId: req.user.id },
      {
        userId: req.user.id,
        location: { type: 'Point', coordinates: [finalLng, finalLat] },
        updatedAt: new Date(),
      },
      { upsert: true, new: true }
    );
    return res.json({ location: doc });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.getMyLocation = async (req, res) => {
  try {
    const doc = await DriverLocation.findOne({ userId: req.user.id });
    if (!doc) return res.status(404).json({ message: 'No location yet' });
    return res.json({ location: doc });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.getDriverLocation = async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await DriverLocation.findOne({ userId: id });
    if (!doc) return res.status(404).json({ message: 'Driver not sharing' });
    return res.json({ location: doc });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};