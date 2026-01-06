const mongoose = require('mongoose');

const forumCommentSchema = new mongoose.Schema({
  postId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ForumPost',
    required: true,
  },
  authorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  images: [String],
  isAcceptedAnswer: {
    type: Boolean,
    default: false,
  },
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
  replies: [
    {
      authorId: mongoose.Schema.Types.ObjectId,
      content: String,
      createdAt: Date,
    },
  ],
  status: {
    type: String,
    enum: ['published', 'edited', 'deleted'],
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

module.exports = mongoose.model('ForumComment', forumCommentSchema);
