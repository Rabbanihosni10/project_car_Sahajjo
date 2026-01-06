const DeviceToken = require('../models/deviceToken');
const Notification = require('../models/notification');

// Register device token
exports.registerToken = async (req, res) => {
  try {
    const { token, deviceType, deviceName } = req.body;
    const userId = req.user.id;

    // Check if token already exists
    let deviceToken = await DeviceToken.findOne({ token });
    if (deviceToken) {
      deviceToken.isActive = true;
      deviceToken.registeredAt = new Date();
      await deviceToken.save();
    } else {
      deviceToken = new DeviceToken({
        userId,
        token,
        deviceType,
        deviceName,
      });
      await deviceToken.save();
    }

    res.status(200).json({
      success: true,
      message: 'Device token registered',
      data: deviceToken,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error registering token',
      error: error.message,
    });
  }
};

// Unregister device token
exports.unregisterToken = async (req, res) => {
  try {
    const { token } = req.body;

    await DeviceToken.findOneAndUpdate({ token }, { isActive: false });

    res.status(200).json({
      success: true,
      message: 'Device token unregistered',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error unregistering token',
      error: error.message,
    });
  }
};

// Send notification to user
exports.sendNotification = async (req, res) => {
  try {
    const { recipientId, title, body, type, relatedId, image, data } = req.body;

    // Get user's device tokens
    const deviceTokens = await DeviceToken.find({ userId: recipientId, isActive: true });

    if (deviceTokens.length === 0) {
      // Still save notification for later retrieval
      const notification = new Notification({
        recipientId,
        title,
        body,
        type,
        relatedId,
        image,
        data,
        status: 'pending',
      });
      await notification.save();

      return res.status(200).json({
        success: true,
        message: 'Notification saved (no active devices)',
        data: notification,
      });
    }

    // Save notification
    const notification = new Notification({
      recipientId,
      title,
      body,
      type,
      relatedId,
      image,
      data,
      status: 'sent',
      sentAt: new Date(),
    });
    await notification.save();

    // TODO: Send via FCM (Firebase Cloud Messaging)
    // For now, emit via Socket.io
    req.io.emit(`notification:${recipientId}`, {
      notificationId: notification._id,
      title,
      body,
      type,
      relatedId,
      image,
      data,
    });

    res.status(200).json({
      success: true,
      message: 'Notification sent',
      data: notification,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error sending notification',
      error: error.message,
    });
  }
};

// Get notifications
exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 20, skip = 0 } = req.query;

    const notifications = await Notification.find({ recipientId: userId })
      .sort({ createdAt: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    const unreadCount = await Notification.countDocuments({
      recipientId: userId,
      isRead: false,
    });

    res.status(200).json({
      success: true,
      data: notifications,
      unreadCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching notifications',
      error: error.message,
    });
  }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;

    const notification = await Notification.findByIdAndUpdate(
      notificationId,
      {
        isRead: true,
        readAt: new Date(),
      },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
      data: notification,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error marking notification',
      error: error.message,
    });
  }
};

// Mark all as read
exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;

    await Notification.updateMany(
      { recipientId: userId, isRead: false },
      {
        isRead: true,
        readAt: new Date(),
      }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error marking notifications',
      error: error.message,
    });
  }
};

// Delete notification
exports.deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;

    await Notification.findByIdAndDelete(notificationId);

    res.status(200).json({
      success: true,
      message: 'Notification deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting notification',
      error: error.message,
    });
  }
};
