const Garage = require('../models/garage');

exports.listGarages = async (req, res) => {
  try {
    const items = await Garage.find({}).limit(200).lean();
    const formatted = items.map(g => ({
      _id: g._id,
      name: g.name,
      address: g.address,
      phone: g.phone,
      rating: g.rating,
      services: g.services,
      longitude: g.location?.coordinates?.[0],
      latitude: g.location?.coordinates?.[1],
    }));
    return res.json({ success: true, data: formatted });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.nearbyGarages = async (req, res) => {
  try {
    const lat = parseFloat(req.query.latitude || req.query.lat);
    const lng = parseFloat(req.query.longitude || req.query.lng);
    const radiusKm = parseFloat(req.query.radius || req.query.radiusKm || '10');
    
    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ message: 'latitude and longitude are required numbers' });
    }
    
    const meters = radiusKm * 1000;
    const items = await Garage.aggregate([
      {
        $geoNear: {
          near: { type: 'Point', coordinates: [lng, lat] },
          spherical: true,
          distanceField: 'distance',
          maxDistance: meters,
        },
      },
      { $limit: 200 },
    ]);
    
    const formatted = items.map(g => ({
      _id: g._id,
      id: g._id,
      name: g.name,
      address: g.address,
      phone: g.phone,
      rating: g.rating,
      services: g.services,
      longitude: g.location?.coordinates?.[0],
      latitude: g.location?.coordinates?.[1],
      distanceMeters: g.distance,
      distanceKm: Math.round((g.distance / 1000) * 100) / 100,
      location: g.location,
    }));
    
    return res.json({ success: true, data: formatted });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// Get garages owned by the current user
exports.getOwnerGarages = async (req, res) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    
    if (!userId) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    
    const garages = await Garage.find({ ownerId: userId }).lean();
    
    const formatted = garages.map(g => ({
      _id: g._id,
      id: g._id,
      name: g.name,
      address: g.address,
      phone: g.phone,
      rating: g.rating,
      services: g.services,
      longitude: g.location?.coordinates?.[0],
      latitude: g.location?.coordinates?.[1],
      location: g.location,
      ownerId: g.ownerId,
    }));
    
    return res.json({ success: true, data: formatted });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.createGarage = async (req, res) => {
  try {
    const { name, address, phone, latitude, longitude, services } = req.body;
    
    if (!name || !address || !phone) {
      return res.status(400).json({ message: 'name, address, and phone are required' });
    }
    
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'latitude and longitude are required' });
    }
    
    const newGarage = new Garage({
      name,
      address,
      phone,
      services: services || [],
      location: {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      },
      ownerId: req.user?.userId || req.user?.id,
    });
    
    await newGarage.save();
    
    return res.status(201).json({
      success: true,
      message: 'Garage created successfully',
      data: {
        _id: newGarage._id,
        name: newGarage.name,
        address: newGarage.address,
        phone: newGarage.phone,
        services: newGarage.services,
        latitude: newGarage.location.coordinates[1],
        longitude: newGarage.location.coordinates[0],
        location: newGarage.location,
        ownerId: newGarage.ownerId,
      },
    });
  } catch (err) {
    console.error('Error creating garage:', err);
    return res.status(500).json({ message: err.message });
  }
};

exports.getGarageById = async (req, res) => {
  try {
    const garage = await Garage.findById(req.params.id).lean();
    
    if (!garage) {
      return res.status(404).json({ message: 'Garage not found' });
    }
    
    const formatted = {
      _id: garage._id,
      name: garage.name,
      address: garage.address,
      phone: garage.phone,
      rating: garage.rating,
      services: garage.services,
      longitude: garage.location?.coordinates?.[0],
      latitude: garage.location?.coordinates?.[1],
      location: garage.location,
    };
    
    return res.json({ success: true, data: formatted });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.updateGarage = async (req, res) => {
  try {
    const { name, address, phone, latitude, longitude, services } = req.body;
    const userId = req.user?.userId || req.user?.id;
    
    // Check if garage exists and user owns it
    const existingGarage = await Garage.findById(req.params.id);
    if (!existingGarage) {
      return res.status(404).json({ message: 'Garage not found' });
    }
    
    // Allow update if user is owner or admin
    if (existingGarage.ownerId && existingGarage.ownerId.toString() !== userId) {
      return res.status(403).json({ message: 'Unauthorized to update this garage' });
    }
    
    const updateData = {};
    if (name) updateData.name = name;
    if (address) updateData.address = address;
    if (phone) updateData.phone = phone;
    if (services) updateData.services = services;
    
    if (latitude && longitude) {
      updateData.location = {
        type: 'Point',
        coordinates: [parseFloat(longitude), parseFloat(latitude)],
      };
    }
    
    const garage = await Garage.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );
    
    return res.json({
      success: true,
      message: 'Garage updated successfully',
      data: garage,
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.deleteGarage = async (req, res) => {
  try {
    const userId = req.user?.userId || req.user?.id;
    
    // Check if garage exists and user owns it
    const existingGarage = await Garage.findById(req.params.id);
    if (!existingGarage) {
      return res.status(404).json({ message: 'Garage not found' });
    }
    
    // Allow delete if user is owner or admin
    if (existingGarage.ownerId && existingGarage.ownerId.toString() !== userId) {
      return res.status(403).json({ message: 'Unauthorized to delete this garage' });
    }
    
    const garage = await Garage.findByIdAndDelete(req.params.id);
    
    return res.json({
      success: true,
      message: 'Garage deleted successfully',
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

exports.seedGarages = async (req, res) => {
  try {
    const baseLat = req.body.lat ? parseFloat(req.body.lat) : 23.8103;
    const baseLng = req.body.lng ? parseFloat(req.body.lng) : 90.4125;
    
    const metersToDegLat = m => m / 111320;
    const metersToDegLng = m => m / (111320 * Math.cos(baseLat * Math.PI / 180));
    
    const offsets = [
      { name: 'Ali Garage', dx: 800, dy: 600 },
      { name: 'QuickFix', dx: -1200, dy: 500 },
      { name: 'Premium Auto', dx: 2000, dy: -1500 },
      { name: 'Dhaka Speed Service', dx: -3000, dy: -1200 },
      { name: 'Gulshan Motor Care', dx: 5000, dy: 2500 },
      { name: 'Banani Auto Hub', dx: -4500, dy: 3000 },
    ];

    const sample = offsets.map((o, i) => {
      const lat = baseLat + metersToDegLat(o.dy);
      const lng = baseLng + metersToDegLng(o.dx);
      return {
        name: o.name,
        address: `${o.name} Location, Dhaka`,
        phone: `01${Math.floor(700000000 + Math.random() * 199999999)}`,
        rating: Math.round((4 + Math.random()) * 10) / 10,
        services: ['Oil Change', 'Brake Service', 'Battery', 'Tires', 'AC Service', 'Engine Repair'].slice(0, 3 + (i % 3)),
        location: { type: 'Point', coordinates: [lng, lat] },
      };
    });
    
    await Garage.deleteMany({});
    await Garage.insertMany(sample);
    
    return res.json({
      success: true,
      message: 'Seeded garages near base location',
      count: sample.length,
      base: { latitude: baseLat, longitude: baseLng },
    });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};
