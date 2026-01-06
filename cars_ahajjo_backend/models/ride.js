const mongoose = require('mongoose');

const rideSchema = new mongoose.Schema(
  {

    // USER REFERENCES

    riderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    driverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },


    // LOCATIONS

    pickupLocation: {
      address: { type: String, required: true },
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },

    dropLocation: {
      address: { type: String, required: true },
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },


    // RIDE DETAILS

    distance: {
      type: Number, // km
      required: true,
    },

    duration: {
      type: Number, // minutes
      required: true,
    },


    // FARE BREAKDOWN

    baseFare: {
      type: Number,
      default: 50, // BDT
    },

    distanceFare: {
      type: Number,
      default: 0,
    },

    timeFare: {
      type: Number,
      default: 0,
    },

    surgeFare: {
      type: Number,
      default: 0,
    },

    tax: {
      type: Number,
      default: 0,
    },

    totalFare: {
      type: Number,
      required: true,
    },

    // RIDE STATUS

    status: {
      type: String,
      enum: ['requested', 'accepted', 'in_progress', 'completed', 'cancelled'],
      default: 'requested',
    },


    // PAYMENT

    paymentMethod: {
      type: String,
      enum: ['cash', 'wallet', 'card', 'sslcommerz'],
      default: 'cash',
    },

    paymentStatus: {
      type: String,
      enum: ['pending', 'completed', 'refunded'],
      default: 'pending',
    },

    transactionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Transaction',
      default: null,
    },

    // RATINGS

    riderRating: {
      rating: { type: Number, min: 1, max: 5 },
      feedback: { type: String },
      ratedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // driver
      },
    },

    driverRating: {
      rating: { type: Number, min: 1, max: 5 },
      feedback: { type: String },
      ratedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User', // rider
      },
    },


    // TIMESTAMPS
    requestedAt: {
      type: Date,
      default: Date.now,
    },

    acceptedAt: Date,
    startedAt: Date,
    completedAt: Date,
    cancelledAt: Date,

    cancellationReason: String,

    notes: String,
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Ride', rideSchema);
