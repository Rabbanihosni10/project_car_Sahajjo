const mongoose = require('mongoose');

const forumPostSchema = new mongoose.Schema({
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    enum: ['general', 'technical', 'marketplace', 'tips', 'events', 'announcements'],
    default: 'general',
  },
  tags: [String],
  images: [String],
  likes: [
    {
      userId: mongoose.Schema.Types.ObjectId,
      createdAt: Date,
    },
  ],
  likeCount: {
    type: Number,
    default: 0,
  },
  views: {
    type: Number,
    default: 0,
  },
  isPinned: {
    type: Boolean,
    default: false,
  },
  isSolved: {
    type: Boolean,
    default: false,
  },
  status: {
    type: String,
    enum: ['published', 'draft', 'deleted'],
    default: 'published',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('ForumPost', forumPostSchema);
