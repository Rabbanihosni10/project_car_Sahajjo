const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      unique: true,
      required: true,
      lowercase: true,
    },
    phone: {
      type: String,
      required: true,
    },
    password: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ['visitor', 'driver', 'owner', 'admin'],
      default: 'visitor',
    },
    // Driver-specific fields
    licenseNumber: String,
    licenseExpiry: String,
    vehicleType: String,
    yearsOfExperience: String,

    // Car Owner-specific fields
    companyName: String,
    businessRegistration: String,
    numberOfCars: String,
    businessType: String,

    // Profile status
    isActive: {
      type: Boolean,
      default: true,
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);