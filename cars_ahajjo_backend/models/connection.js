const mongoose = require('mongoose');

const connectionSchema = new mongoose.Schema(
  {
    initiatorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    recipientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'blocked', 'rejected'],
      default: 'pending',
    },
    connectionType: {
      type: String,
      enum: ['friend', 'follow', 'colleague', 'community'],
      default: 'friend',
    },
    // Following functionality
    isFollowing: {
      type: Boolean,
      default: false,
    },
    followerCount: {
      type: Number,
      default: 0,
    },
    followingCount: {
      type: Number,
      default: 0,
    },
    // Mutual friends count
    mutualFriendsCount: {
      type: Number,
      default: 0,
    },
    // Notes about the connection
    note: String,
    // Block functionality
    blockedAt: Date,
    blockedReason: String,
    // Timestamps
    requestedAt: Date,
    acceptedAt: Date,
  },
  { timestamps: true }
);

// Compound index to prevent duplicate connections
connectionSchema.index({ initiatorId: 1, recipientId: 1 }, { unique: true });

module.exports = mongoose.model('Connection', connectionSchema);
