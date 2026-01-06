const User = require("../models/user");
const Message = require("../models/message");
const Transaction = require("../models/transaction");
const Rating = require("../models/rating");

// Get Dashboard Statistics
exports.getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const driverCount = await User.countDocuments({ role: "driver" });
    const ownerCount = await User.countDocuments({ role: "owner" });
    const visitorCount = await User.countDocuments({ role: "visitor" });
    const garageCount = await User.countDocuments({ role: "garage" });

    const totalTransactions = await Transaction.countDocuments();
    const totalRevenue = await Transaction.aggregate([
      { $match: { status: "completed" } },
      { $group: { _id: null, total: { $sum: "$amount" } } },
    ]);

    const totalRatings = await Rating.countDocuments();
    const avgRating = await Rating.aggregate([
      { $group: { _id: null, avg: { $avg: "$rating" } } },
    ]);

    const recentMessages = await Message.countDocuments();

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        driverCount,
        ownerCount,
        visitorCount,
        garageCount,
        totalTransactions,
        totalRevenue: totalRevenue[0]?.total || 0,
        totalRatings,
        avgRating: avgRating[0]?.avg || 0,
        recentMessages,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching dashboard stats",
      error: error.message,
    });
  }
};

// Get All Users with Filters
exports.getAllUsers = async (req, res) => {
  try {
    const { role, status, search, limit = 10, skip = 0 } = req.query;
    let filter = {};

    if (role) filter.role = role;
    if (status) filter.isActive = status === "active";
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: "i" } },
        { email: { $regex: search, $options: "i" } },
        { phone: { $regex: search, $options: "i" } },
      ];
    }

    const users = await User.find(filter)
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .select("-password")
      .sort({ createdAt: -1 });

    const total = await User.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: users,
      total,
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching users",
      error: error.message,
    });
  }
};

// Get User Details
exports.getUserDetails = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).select("-password");

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Get user's ratings
    const ratings = await Rating.find({ ratedUserId: userId });
    const avgRating = ratings.length
      ? ratings.reduce((sum, r) => sum + r.rating, 0) / ratings.length
      : 0;

    // Get user's transactions
    const transactions = await Transaction.find({
      $or: [{ payerId: userId }, { receiverId: userId }],
    }).limit(10);

    res.status(200).json({
      success: true,
      data: {
        user,
        avgRating,
        ratingCount: ratings.length,
        recentTransactions: transactions,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching user details",
      error: error.message,
    });
  }
};

// Ban/Unban User
exports.toggleUserBan = async (req, res) => {
  try {
    const { userId } = req.params;
    const { isBanned } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { isBanned },
      { new: true }
    ).select("-password");

    res.status(200).json({
      success: true,
      message: `User ${isBanned ? "banned" : "unbanned"} successfully`,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error updating user ban status",
      error: error.message,
    });
  }
};

// Deactivate User
exports.deactivateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { isActive: false, deactivationReason: reason, deactivatedAt: new Date() },
      { new: true }
    ).select("-password");

    res.status(200).json({
      success: true,
      message: "User deactivated successfully",
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error deactivating user",
      error: error.message,
    });
  }
};

// Get All Transactions with Filters
exports.getTransactions = async (req, res) => {
  try {
    const { status, startDate, endDate, limit = 15, skip = 0 } = req.query;
    let filter = {};

    if (status) filter.status = status;
    if (startDate || endDate) {
      filter.createdAt = {};
      if (startDate) filter.createdAt.$gte = new Date(startDate);
      if (endDate) filter.createdAt.$lte = new Date(endDate);
    }

    const transactions = await Transaction.find(filter)
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    const total = await Transaction.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: transactions,
      total,
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching transactions",
      error: error.message,
    });
  }
};

// Get Revenue Statistics
exports.getRevenueStats = async (req, res) => {
  try {
    const { period = "monthly" } = req.query;

    const groupStage =
      period === "daily"
        ? { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }
        : period === "weekly"
        ? { $week: "$createdAt" }
        : { $dateToString: { format: "%Y-%m", date: "$createdAt" } };

    const stats = await Transaction.aggregate([
      { $match: { status: "completed" } },
      {
        $group: {
          _id: groupStage,
          revenue: { $sum: "$amount" },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching revenue stats",
      error: error.message,
    });
  }
};

// Get All Ratings with Filters
exports.getRatings = async (req, res) => {
  try {
    const { minRating, userId, limit = 15, skip = 0 } = req.query;
    let filter = {};

    if (minRating) filter.rating = { $gte: parseInt(minRating) };
    if (userId) filter.ratedUserId = userId;

    const ratings = await Rating.find(filter)
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    const total = await Rating.countDocuments(filter);

    res.status(200).json({
      success: true,
      data: ratings,
      total,
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching ratings",
      error: error.message,
    });
  }
};

// Flag/Remove Rating
exports.toggleRatingFlag = async (req, res) => {
  try {
    const { ratingId } = req.params;
    const { isFlagged } = req.body;

    const rating = await Rating.findByIdAndUpdate(
      ratingId,
      { isFlagged, flaggedAt: isFlagged ? new Date() : null },
      { new: true }
    );

    res.status(200).json({
      success: true,
      message: `Rating ${isFlagged ? "flagged" : "unflagged"} successfully`,
      data: rating,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error updating rating flag status",
      error: error.message,
    });
  }
};

// Get System Logs/Activity
exports.getSystemLogs = async (req, res) => {
  try {
    const { limit = 20, skip = 0 } = req.query;

    // Get recent messages (as activity indicator)
    const recentMessages = await Message.find()
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    // Get recent ratings
    const recentRatings = await Rating.find()
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    // Get recent transactions
    const recentTransactions = await Transaction.find()
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: {
        messages: recentMessages,
        ratings: recentRatings,
        transactions: recentTransactions,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching system logs",
      error: error.message,
    });
  }
};

// Send Notification/Announcement
exports.sendAnnouncement = async (req, res) => {
  try {
    const { title, message, targetRole, recipientIds } = req.body;

    // Emit announcement via Socket.io to all connected clients
    try {
      if (req.io) {
        req.io.emit("announcement", {
          title,
          message,
          targetRole,
          recipientIds,
          sentAt: new Date(),
        });
      }
    } catch (socketErr) {
      console.error("Socket emit failed:", socketErr.message);
    }

    res.status(200).json({
      success: true,
      message: "Announcement sent successfully",
      data: {
        title,
        message,
        targetRole,
        sentAt: new Date(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error sending announcement",
      error: error.message,
    });
  }
};

// Get Platform Health Check
exports.getHealthCheck = async (req, res) => {
  try {
    const userCount = await User.countDocuments();
    const messageCount = await Message.countDocuments();
    const transactionCount = await Transaction.countDocuments();
    const ratingCount = await Rating.countDocuments();

    res.status(200).json({
      success: true,
      status: "healthy",
      data: {
        timestamp: new Date(),
        userCount,
        messageCount,
        transactionCount,
        ratingCount,
        uptime: process.uptime(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      status: "unhealthy",
      message: "Health check failed",
      error: error.message,
    });
  }
};
