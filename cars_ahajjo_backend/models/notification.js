const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  body: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['ride_request', 'ride_accepted', 'ride_completed', 'payment', 'job', 'order', 'message', 'forum', 'admin'],
    default: 'admin',
  },
  relatedId: String, // rideId, jobId, orderId, etc.
  image: String,
  data: {
    type: Map,
    of: String, // Additional data for deep linking
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  readAt: Date,
  status: {
    type: String,
    enum: ['pending', 'sent', 'failed', 'delivered'],
    default: 'pending',
  },
  sentAt: Date,
  deliveredAt: Date,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Notification', notificationSchema);
