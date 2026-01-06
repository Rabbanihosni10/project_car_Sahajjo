const mongoose = require('mongoose');

const MapPlaceSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, trim: true },
    address: { type: String, trim: true },
    category: { type: String, default: 'custom' },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        index: '2dsphere',
        required: true,
      },
    },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

// Ensure location is synced whenever lat/lng set
MapPlaceSchema.pre('save', function setLocation(next) {
  if (this.isModified('latitude') || this.isModified('longitude')) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude],
    };
  }
  next();
});

module.exports = mongoose.model('MapPlace', MapPlaceSchema);
