const mongoose = require('mongoose');

const deviceTokenSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  token: {
    type: String,
    required: true,
    unique: true,
  },
  deviceType: {
    type: String,
    enum: ['ios', 'android', 'web'],
    default: 'android',
  },
  deviceName: String,
  isActive: {
    type: Boolean,
    default: true,
  },
  registeredAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('DeviceToken', deviceTokenSchema);
