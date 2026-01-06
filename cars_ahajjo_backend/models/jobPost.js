const mongoose = require('mongoose');

const jobPostSchema = new mongoose.Schema(
  {
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    title: String,
    description: String,
    carModel: String,
    location: {
      address: String,
      latitude: Number,
      longitude: Number,
    },
    salary: Number, // Monthly or daily
    salaryType: {
      type: String,
      enum: ['monthly', 'daily', 'hourly'],
    },
    jobType: {
      type: String,
      enum: ['full_time', 'part_time', 'contract', 'full-time', 'part-time'],
    },
    experience: String, // e.g., "2+ years"
    licenseType: String, // e.g., "HTV"
    workingHours: {
      type: [String],
      default: [],
    },
    requirements: [String],
    perks: [String],
    status: {
      type: String,
      enum: ['open', 'closed', 'filled'],
      default: 'open',
    },
    applicants: [
      {
        driverId: mongoose.Schema.Types.ObjectId,
        appliedAt: Date,
        status: {
          type: String,
          enum: ['pending', 'interviewed', 'accepted', 'rejected'],
          default: 'pending',
        },
        notes: String,
      },
    ],
    selectedDriver: mongoose.Schema.Types.ObjectId,
    contractUrl: String,
    postedAt: Date,
    expiryDate: Date,
  },
  { timestamps: true }
);

module.exports = mongoose.model('JobPost', jobPostSchema);
