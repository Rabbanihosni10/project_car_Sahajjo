const mongoose = require('mongoose');

const garageSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    address: { type: String },
    phone: { type: String },
    rating: { type: Number, default: 0 },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true,
      },
      coordinates: {
        type: [Number], // [lng, lat]
        required: true,
      },
    },
    services: [{ type: String }],
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      index: true,
    },
  },
  { timestamps: true }
);

garageSchema.index({ location: '2dsphere' });
garageSchema.index({ ownerId: 1 });

module.exports = mongoose.model('Garage', garageSchema);
