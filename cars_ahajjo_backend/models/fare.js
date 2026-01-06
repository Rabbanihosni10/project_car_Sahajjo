const mongoose = require('mongoose');

const fareSchema = new mongoose.Schema({
  rideId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ride',
    required: true,
  },
  riderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  distance: {
    type: Number,
    required: true, // km
  },
  durationMinutes: {
    type: Number,
    required: true, // minutes
  },
  fare: {
    type: Number,
    required: true, // Base fare
  },
  tax: {
    type: Number,
    default: 0,
  },
  total: {
    type: Number,
    required: true, // fare + tax
  },
  surgeMultiplier: {
    type: Number,
    default: 1.0,
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'mobile_wallet', 'ssl_commerz'],
    default: 'cash',
  },
  currency: {
    type: String,
    default: 'BDT',
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'refunded'],
    default: 'completed',
  },
  notes: String,
  recordedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Fare', fareSchema);
