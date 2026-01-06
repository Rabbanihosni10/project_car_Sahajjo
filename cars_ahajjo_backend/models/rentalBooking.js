const mongoose = require('mongoose');

const rentalBookingSchema = new mongoose.Schema({
  rentalId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CarRental',
    required: true,
  },
  renterId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  bookingNo: {
    type: String,
    unique: true,
    default: () => `RENT-${Date.now()}`,
  },
  pickupDate: {
    type: Date,
    required: true,
  },
  returnDate: {
    type: Date,
    required: true,
  },
  pickupLocation: String,
  returnLocation: String,
  numberOfDays: Number,
  dailyRate: Number,
  monthlyRate: Number,
  totalRentalCost: {
    type: Number,
    required: true,
  },
  deposit: {
    amount: Number,
    status: {
      type: String,
      enum: ['pending', 'collected', 'refunded'],
      default: 'pending',
    },
    paidDate: Date,
    refundDate: Date,
  },
  insurance: {
    selected: Boolean,
    type: String,
    cost: Number,
  },
  additionalCharges: {
    type: Map,
    of: Number,
    default: new Map(), // e.g., { 'extra_driver': 500, 'gps': 200 }
  },
  payment: {
    totalAmount: {
      type: Number,
      required: true, // rental + insurance + charges
    },
    method: {
      type: String,
      enum: ['cash', 'card', 'ssl_commerz', 'stripe'],
      default: 'cash',
    },
    status: {
      type: String,
      enum: ['pending', 'completed', 'refunded'],
      default: 'pending',
    },
    transactionId: String,
    paidDate: Date,
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'active', 'completed', 'cancelled'],
    default: 'pending',
  },
  documents: {
    driverLicense: String,
    insuranceProof: String,
    identification: String,
  },
  renterDetails: {
    name: String,
    email: String,
    phone: String,
    address: String,
    licenseNumber: String,
  },
  carCondition: {
    beforePickup: {
      description: String,
      images: [String],
      recordedAt: Date,
    },
    afterReturn: {
      description: String,
      images: [String],
      recordedAt: Date,
      damageReport: String,
    },
  },
  mileage: {
    atPickup: Number,
    atReturn: Number,
    additionalCharge: Number,
  },
  feedback: {
    renterRating: Number,
    renterReview: String,
    ownerRating: Number,
    ownerReview: String,
  },
  cancellation: {
    requestedAt: Date,
    cancelledAt: Date,
    reason: String,
    refundAmount: Number,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('RentalBooking', rentalBookingSchema);
