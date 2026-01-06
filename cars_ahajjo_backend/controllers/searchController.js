const User = require('../models/user');
const Garage = require('../models/garage');

// Search drivers by name, email, or phone
exports.searchDrivers = async (req, res) => {
  try {
    const { query, limit = 10, skip = 0 } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters',
      });
    }

    const drivers = await User.find(
      {
        role: 'driver',
        isActive: true,
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { email: { $regex: query, $options: 'i' } },
          { phone: { $regex: query, $options: 'i' } },
        ],
      },
      { password: 0 } // Exclude password
    )
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await User.countDocuments({
      role: 'driver',
      isActive: true,
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } },
        { phone: { $regex: query, $options: 'i' } },
      ],
    });

    res.status(200).json({
      success: true,
      data: drivers,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error searching drivers',
      error: error.message,
    });
  }
};

// Search car owners
exports.searchOwners = async (req, res) => {
  try {
    const { query, limit = 10, skip = 0 } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters',
      });
    }

    const owners = await User.find(
      {
        role: 'owner',
        isActive: true,
        $or: [
          { name: { $regex: query, $options: 'i' } },
          { companyName: { $regex: query, $options: 'i' } },
          { email: { $regex: query, $options: 'i' } },
          { phone: { $regex: query, $options: 'i' } },
        ],
      },
      { password: 0 }
    )
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await User.countDocuments({
      role: 'owner',
      isActive: true,
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { companyName: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } },
        { phone: { $regex: query, $options: 'i' } },
      ],
    });

    res.status(200).json({
      success: true,
      data: owners,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error searching owners',
      error: error.message,
    });
  }
};

// Filter drivers by experience, vehicle type, rating
exports.filterDrivers = async (req, res) => {
  try {
    const {
      yearsOfExperience,
      vehicleType,
      minRating = 0,
      limit = 10,
      skip = 0,
    } = req.query;

    const filter = { role: 'driver', isActive: true };

    if (yearsOfExperience) {
      filter.yearsOfExperience = { $gte: yearsOfExperience };
    }

    if (vehicleType) {
      filter.vehicleType = vehicleType;
    }

    const drivers = await User.find(filter, { password: 0 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await User.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: drivers,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error filtering drivers',
      error: error.message,
    });
  }
};

// Search garages by name or city
exports.searchGarages = async (req, res) => {
  try {
    const { query, limit = 10, skip = 0 } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters',
      });
    }

    const garages = await Garage.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { address: { $regex: query, $options: 'i' } },
        { city: { $regex: query, $options: 'i' } },
      ],
    })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Garage.countDocuments({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { address: { $regex: query, $options: 'i' } },
        { city: { $regex: query, $options: 'i' } },
      ],
    });

    res.status(200).json({
      success: true,
      data: garages,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error searching garages',
      error: error.message,
    });
  }
};

// Filter garages by services
exports.filterGarages = async (req, res) => {
  try {
    const { services, limit = 10, skip = 0 } = req.query;

    const filter = {};

    if (services) {
      // Assuming services is a comma-separated string
      const serviceArray = services.split(',');
      filter.services = { $in: serviceArray };
    }

    const garages = await Garage.find(filter)
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Garage.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: garages,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error filtering garages',
      error: error.message,
    });
  }
};
