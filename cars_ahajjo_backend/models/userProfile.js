const mongoose = require('mongoose');

const userProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    bio: {
      type: String,
      maxlength: 500,
    },
    avatar: {
      type: String, // URL to profile picture
    },
    coverImage: {
      type: String, // URL to cover image
    },
    location: String,
    profession: String,
    website: String,
    dateOfBirth: Date,
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
    },
    // Interests/Tags
    interests: [
      {
        type: String,
      },
    ],
    // Statistics
    followerCount: {
      type: Number,
      default: 0,
    },
    followingCount: {
      type: Number,
      default: 0,
    },
    friendCount: {
      type: Number,
      default: 0,
    },
    ratingsCount: {
      type: Number,
      default: 0,
    },
    averageRating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    // Verification badges
    isVerifiedDriver: {
      type: Boolean,
      default: false,
    },
    isVerifiedOwner: {
      type: Boolean,
      default: false,
    },
    isVerifiedMechanic: {
      type: Boolean,
      default: false,
    },
    // Visibility settings
    isProfilePublic: {
      type: Boolean,
      default: true,
    },
    allowDirectMessages: {
      type: Boolean,
      default: true,
    },
    allowConnectionRequests: {
      type: Boolean,
      default: true,
    },
    // Last activity
    lastActiveAt: Date,
    // Social links
    socialLinks: {
      facebook: String,
      instagram: String,
      twitter: String,
      linkedIn: String,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserProfile', userProfileSchema);
