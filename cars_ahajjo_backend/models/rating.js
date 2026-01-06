const mongoose = require('mongoose');

const ratingSchema = new mongoose.Schema(
  {
    ratedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    ratedUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
      required: true,
    },
    review: String,
    rideId: mongoose.Schema.Types.ObjectId, // Related ride/trip
    categories: {
      // For drivers
      drivingSkill: Number, // 1-5
      courtesy: Number, // 1-5
      carCondition: Number, // 1-5

      // For owners
      paymentHandling: Number, // 1-5
      carMaintenance: Number, // 1-5
      communication: Number, // 1-5
    },
    isAnonymous: {
      type: Boolean,
      default: false,
    },
    isVerified: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Rating', ratingSchema);
