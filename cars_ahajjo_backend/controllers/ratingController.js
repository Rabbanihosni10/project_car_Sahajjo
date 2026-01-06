const Rating = require('../models/rating');
const User = require('../models/user');

// Submit a rating/review
exports.submitRating = async (req, res) => {
  try {
    const userId = req.user.id;
    const { ratedUserId, rating, review, categories, rideId, isAnonymous } =
      req.body;

    if (!ratedUserId || !rating) {
      return res.status(400).json({
        success: false,
        message: 'Rated user ID and rating are required',
      });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5',
      });
    }

    // Check if user already rated this person for this ride
    if (rideId) {
      const existingRating = await Rating.findOne({
        ratedBy: userId,
        ratedUser: ratedUserId,
        rideId,
      });

      if (existingRating) {
        return res.status(400).json({
          success: false,
          message: 'You have already rated this user for this ride',
        });
      }
    }

    const newRating = new Rating({
      ratedBy: userId,
      ratedUser: ratedUserId,
      rating,
      review,
      rideId,
      isAnonymous: isAnonymous || false,
      categories: categories || {},
    });

    await newRating.save();
    await newRating.populate('ratedBy', 'name email phone');
    await newRating.populate('ratedUser', 'name email');

    res.status(201).json({
      success: true,
      message: 'Rating submitted successfully',
      data: newRating,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error submitting rating',
      error: error.message,
    });
  }
};

// Get ratings for a user
exports.getUserRatings = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10, skip = 0 } = req.query;

    const ratings = await Rating.find({ ratedUser: userId })
      .populate('ratedBy', 'name email phone')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip));

    const total = await Rating.countDocuments({ ratedUser: userId });

    // Calculate average rating
    const avgRating = await Rating.aggregate([
      { $match: { ratedUser: require('mongoose').Types.ObjectId(userId) } },
      { $group: { _id: null, average: { $avg: '$rating' } } },
    ]);

    res.status(200).json({
      success: true,
      data: ratings,
      averageRating: avgRating.length > 0 ? avgRating[0].average : 0,
      totalRatings: total,
      pagination: {
        total,
        limit: parseInt(limit),
        skip: parseInt(skip),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching ratings',
      error: error.message,
    });
  }
};

// Get rating summary for a user
exports.getRatingSummary = async (req, res) => {
  try {
    const { userId } = req.params;

    const ratings = await Rating.find({ ratedUser: userId });

    if (ratings.length === 0) {
      return res.status(200).json({
        success: true,
        data: {
          totalRatings: 0,
          averageRating: 0,
          ratingDistribution: {
            5: 0,
            4: 0,
            3: 0,
            2: 0,
            1: 0,
          },
        },
      });
    }

    // Calculate average
    const totalRating = ratings.reduce((sum, r) => sum + r.rating, 0);
    const averageRating = (totalRating / ratings.length).toFixed(1);

    // Calculate distribution
    const distribution = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
    ratings.forEach((rating) => {
      distribution[rating.rating]++;
    });

    res.status(200).json({
      success: true,
      data: {
        totalRatings: ratings.length,
        averageRating: parseFloat(averageRating),
        ratingDistribution: distribution,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching rating summary',
      error: error.message,
    });
  }
};

// Update a rating
exports.updateRating = async (req, res) => {
  try {
    const { ratingId } = req.params;
    const userId = req.user.id;
    const { rating, review, categories } = req.body;

    const ratingDoc = await Rating.findById(ratingId);
    if (!ratingDoc) {
      return res.status(404).json({
        success: false,
        message: 'Rating not found',
      });
    }

    if (ratingDoc.ratedBy.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own ratings',
      });
    }

    if (rating && (rating < 1 || rating > 5)) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5',
      });
    }

    if (rating) ratingDoc.rating = rating;
    if (review) ratingDoc.review = review;
    if (categories) ratingDoc.categories = categories;

    await ratingDoc.save();
    await ratingDoc.populate('ratedBy', 'name email phone');
    await ratingDoc.populate('ratedUser', 'name email');

    res.status(200).json({
      success: true,
      message: 'Rating updated successfully',
      data: ratingDoc,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating rating',
      error: error.message,
    });
  }
};

// Delete a rating
exports.deleteRating = async (req, res) => {
  try {
    const { ratingId } = req.params;
    const userId = req.user.id;

    const ratingDoc = await Rating.findById(ratingId);
    if (!ratingDoc) {
      return res.status(404).json({
        success: false,
        message: 'Rating not found',
      });
    }

    if (ratingDoc.ratedBy.toString() !== userId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own ratings',
      });
    }

    await Rating.findByIdAndDelete(ratingId);

    res.status(200).json({
      success: true,
      message: 'Rating deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting rating',
      error: error.message,
    });
  }
};
