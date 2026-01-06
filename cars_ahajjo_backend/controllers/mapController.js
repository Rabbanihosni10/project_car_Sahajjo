const Garage = require('../models/garage');
const DriverLocation = require('../models/driverLocation');
const User = require('../models/user');
const MapPlace = require('../models/mapPlace');

exports.getMyLocation = async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId).select('name email role');

    const baseLat = 23.8103;
    const baseLng = 90.4125;
    const variance = 0.005; // ~500 meters

    const myLocation = {
      userId,
      name: user.name,
      role: user.role,
      latitude: baseLat + (Math.random() - 0.5) * variance,
      longitude: baseLng + (Math.random() - 0.5) * variance,
      timestamp: new Date(),
    };

    res.json({ success: true, data: myLocation });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Get nearby garages from user's location
 * GET /api/map/nearby-garages?lat=...&lng=...&radiusKm=5
 */
exports.getNearbyGarages = async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat || '23.8103');
    const lng = parseFloat(req.query.lng || '90.4125');
    const radiusKm = parseFloat(req.query.radiusKm || '5');

    const meters = radiusKm * 1000;

    const garages = await Garage.aggregate([
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [lng, lat] },
          spherical: true,
          distanceField: 'distance',
          maxDistance: meters,
        },
      },
      { $limit: 50 },
    ]);

    const formatted = garages.map(g => ({
      _id: g._id,
      name: g.name,
      address: g.address,
      phone: g.phone,
      rating: g.rating,
      services: g.services,
      latitude: g.location?.coordinates?.[1],
      longitude: g.location?.coordinates?.[0],
      distanceKm: Math.round((g.distance / 1000) * 100) / 100,
    }));

    res.json({ success: true, garages: formatted });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Generate random driver location far from owner (for owner view)
 * GET /api/map/driver-locations?ownerLat=...&ownerLng=...
 */
exports.getDriverLocations = async (req, res) => {
  try {
    const ownerLat = parseFloat(req.query.ownerLat || '23.8103');
    const ownerLng = parseFloat(req.query.ownerLng || '90.4125');

    // Generate 3-5 random driver locations far from owner (2-8 km away)
    const driverCount = 3 + Math.floor(Math.random() * 3);
    const drivers = [];

    for (let i = 0; i < driverCount; i++) {
      // Random distance 2-8 km
      const distanceKm = 2 + Math.random() * 6;
      // Random angle 0-360 degrees
      const angle = Math.random() * 360;

      // Convert to lat/lng offset
      const dLat = (distanceKm / 111) * Math.cos((angle * Math.PI) / 180);
      const dLng = (distanceKm / (111 * Math.cos((ownerLat * Math.PI) / 180))) * Math.sin((angle * Math.PI) / 180);

      drivers.push({
        driverId: `driver_${i + 1}`,
        driverName: `Driver ${i + 1}`,
        latitude: ownerLat + dLat,
        longitude: ownerLng + dLng,
        distanceKm: Math.round(distanceKm * 100) / 100,
        status: ['available', 'en-route', 'busy'][Math.floor(Math.random() * 3)],
        vehicle: ['Toyota Corolla', 'Honda Civic', 'Suzuki Swift', 'Toyota Axio'][Math.floor(Math.random() * 4)],
        rating: (Math.random() * 2 + 3).toFixed(1),
      });
    }

    res.json({ success: true, drivers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Get traffic info (mock data - in production use Google Maps API)
 * GET /api/map/traffic?lat=...&lng=...
 */
exports.getTrafficInfo = async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat || '23.8103');
    const lng = parseFloat(req.query.lng || '90.4125');

    // Mock traffic conditions - simulate real traffic patterns
    const trafficLevels = [
      { area: 'Dhaka Downtown', level: 'heavy', color: '#dc2626', vehicles: 150 },
      { area: 'Gulshan', level: 'moderate', color: '#f97316', vehicles: 80 },
      { area: 'Banani', level: 'light', color: '#22c55e', vehicles: 40 },
      { area: 'Mirpur', level: 'heavy', color: '#dc2626', vehicles: 130 },
    ];

    // Return traffic with severity levels
    res.json({
      success: true,
      traffic: trafficLevels,
      legend: {
        heavy: { color: '#dc2626', avgSpeed: '10-15 km/h' },
        moderate: { color: '#f97316', avgSpeed: '20-35 km/h' },
        light: { color: '#22c55e', avgSpeed: '40+ km/h' },
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Get route directions for a driver
 * POST /api/map/route-directions
 * Body: { startLat, startLng, endLat, endLng }
 */
exports.getRouteDirections = async (req, res) => {
  try {
    const { startLat, startLng, endLat, endLng } = req.body;

    if (!startLat || !startLng || !endLat || !endLng) {
      return res.status(400).json({ success: false, message: 'Start and end coordinates required' });
    }

    // Calculate rough distance (Haversine formula)
    const R = 6371; // Earth's radius in km
    const dLat = ((endLat - startLat) * Math.PI) / 180;
    const dLng = ((endLng - startLng) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((startLat * Math.PI) / 180) * Math.cos((endLat * Math.PI) / 180) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    // Estimate duration (average 25 km/h in Dhaka traffic)
    const duration = Math.ceil((distance / 25) * 60); // in minutes

    // Mock route waypoints (simplified)
    const waypoints = [
      { lat: startLat, lng: startLng, instruction: 'Start' },
      {
        lat: (startLat + endLat) / 2,
        lng: (startLng + endLng) / 2,
        instruction: 'Continue on main road',
      },
      { lat: endLat, lng: endLng, instruction: 'Arrive at destination' },
    ];

    res.json({
      success: true,
      route: {
        distanceKm: Math.round(distance * 100) / 100,
        durationMinutes: duration,
        waypoints,
        trafficDelay: Math.floor(Math.random() * 15) + 5, // 5-20 min delay
        estimatedArrival: new Date(Date.now() + duration * 60 * 1000),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Seed sample driver locations (for testing)
 * POST /api/map/seed-drivers
 */
exports.seedDriverLocations = async (req, res) => {
  try {
    const drivers = [
      {
        driverId: 'driver_001',
        latitude: 23.82,
        longitude: 90.42,
        status: 'available',
      },
      {
        driverId: 'driver_002',
        latitude: 23.79,
        longitude: 90.41,
        status: 'en-route',
      },
      {
        driverId: 'driver_003',
        latitude: 23.81,
        longitude: 90.43,
        status: 'busy',
      },
    ];

    await DriverLocation.deleteMany({});
    await DriverLocation.insertMany(drivers);

    res.json({ success: true, message: 'Seeded driver locations', count: drivers.length });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Add a user-contributed place
 * POST /api/map/places
 * Body: { name, latitude, longitude, address?, description?, category? }
 */
exports.addPlace = async (req, res) => {
  try {
    const { name, latitude, longitude, address, description, category } = req.body;

    if (!name || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ success: false, message: 'Name, latitude, and longitude are required' });
    }

    const place = await MapPlace.create({
      name,
      latitude,
      longitude,
      address,
      description,
      category,
      createdBy: req.user.id,
      location: { type: 'Point', coordinates: [longitude, latitude] },
    });

    res.status(201).json({ success: true, data: place });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Get places created by the user
 * GET /api/map/places
 */
exports.getPlaces = async (req, res) => {
  try {
    const places = await MapPlace.find({ createdBy: req.user.id }).sort({ createdAt: -1 });
    res.json({ success: true, data: places });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

/**
 * Delete a user-contributed place
 * DELETE /api/map/places/:id
 */
exports.deletePlace = async (req, res) => {
  try {
    const place = await MapPlace.findById(req.params.id);
    if (!place) {
      return res.status(404).json({ success: false, message: 'Place not found' });
    }

    const isOwner = place.createdBy.toString() === req.user.id;
    const isAdmin = req.user.role === 'admin';
    if (!isOwner && !isAdmin) {
      return res.status(403).json({ success: false, message: 'Not authorized to delete this place' });
    }

    await place.deleteOne();
    res.json({ success: true, message: 'Place deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
