const mongoose = require('mongoose');

const carRentalSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  carId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Car',
  },
  carName: String,
  carModel: String,
  registrationNumber: String,
  image: String,
  category: {
    type: String,
    enum: ['economy', 'sedan', 'suv', 'luxury', 'van'],
    default: 'sedan',
  },
  location: String,
  pricePerDay: {
    type: Number,
    required: true, // BDT
  },
  pricePerMonth: {
    type: Number,
    required: true, // BDT
  },
  capacity: {
    type: Number,
    default: 5,
  },
  features: [String], // AC, Power Steering, ABS, etc.
  documents: {
    registrationCertificate: String,
    insuranceCertificate: String,
    roadsideAssistance: String,
  },
  availability: {
    startDate: Date,
    endDate: Date,
    blockedDates: [Date],
  },
  deposit: {
    required: Boolean,
    amount: Number, // BDT
    refundableWithin: Number, // days
  },
  insurance: {
    included: Boolean,
    type: String, // basic, comprehensive
    coverage: String,
  },
  cancellationPolicy: {
    freeCancellationBefore: Number, // hours
    partialRefund: Number, // percentage
  },
  ratings: {
    average: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    count: {
      type: Number,
      default: 0,
    },
  },
  status: {
    type: String,
    enum: ['active', 'inactive', 'maintenance'],
    default: 'active',
  },
  totalBookings: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('CarRental', carRentalSchema);
