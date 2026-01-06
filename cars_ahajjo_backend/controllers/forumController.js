const ForumPost = require('../models/forumPost');
const ForumComment = require('../models/forumComment');

// ===== POST MANAGEMENT =====
exports.createPost = async (req, res) => {
  try {
    const { title, content, category, tags } = req.body;

    // Validate required fields
    if (!title || !content) {
      return res.status(400).json({
        success: false,
        message: 'Title and content are required',
      });
    }

    const post = new ForumPost({
      authorId: req.user.id,
      title,
      content,
      category: category || 'general',
      tags: tags || [],
    });

    await post.save();
    
    // Try to populate, but don't fail if it doesn't work
    try {
      await post.populate('authorId', 'name email');
    } catch (populateError) {
      console.log('Populate warning:', populateError.message);
    }

    // Emit socket event if io is available
    if (req.io) {
      try {
        req.io.emit('new_forum_post', {
          postId: post._id,
          title,
          category,
          message: `New post: ${title}`,
        });
      } catch (socketError) {
        console.log('Socket emit warning:', socketError.message);
      }
    }

    res.status(201).json({
      success: true,
      message: 'Post created successfully',
      data: post,
    });
  } catch (error) {
    console.error('Error creating post:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating post',
      error: error.message,
    });
  }
};

exports.getPosts = async (req, res) => {
  try {
    const { category, search, sortBy = 'newest' } = req.query;

    const query = { status: 'published' };
    if (category) query.category = category;
    if (search) {
      query.$or = [
        { title: new RegExp(search, 'i') },
        { content: new RegExp(search, 'i') },
        { tags: search },
      ];
    }

    let posts = await ForumPost.find(query)
      .populate('authorId', 'name avatar')
      .limit(50);

    if (sortBy === 'oldest') posts.reverse();
    if (sortBy === 'popular') posts.sort((a, b) => b.views - a.views);
    if (sortBy === 'likes') posts.sort((a, b) => b.likeCount - a.likeCount);

    res.status(200).json({ success: true, data: posts });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching posts',
      error: error.message,
    });
  }
};

exports.getPostDetails = async (req, res) => {
  try {
    const { postId } = req.params;

    const post = await ForumPost.findByIdAndUpdate(
      postId,
      { $inc: { views: 1 } },
      { new: true }
    ).populate('authorId', 'name avatar email');

    if (!post) {
      return res.status(404).json({ success: false, message: 'Post not found' });
    }

    const comments = await ForumComment.find({ postId, status: 'published' })
      .populate('authorId', 'name avatar')
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: {
        post,
        comments,
        commentCount: comments.length,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching post',
      error: error.message,
    });
  }
};

exports.updatePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { title, content, category, tags } = req.body;
    const userId = req.user.id;

    const post = await ForumPost.findById(postId);
    if (!post || post.authorId.toString() !== userId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    post.title = title || post.title;
    post.content = content || post.content;
    post.category = category || post.category;
    post.tags = tags || post.tags;
    post.updatedAt = new Date();

    await post.save();

    res.status(200).json({
      success: true,
      message: 'Post updated',
      data: post,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating post',
      error: error.message,
    });
  }
};

exports.deletePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    const post = await ForumPost.findById(postId);
    if (!post || post.authorId.toString() !== userId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    post.status = 'deleted';
    await post.save();

    res.status(200).json({
      success: true,
      message: 'Post deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting post',
      error: error.message,
    });
  }
};

// ===== COMMENT MANAGEMENT =====
exports.addComment = async (req, res) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;

    const post = await ForumPost.findById(postId);
    if (!post) {
      return res.status(404).json({ success: false, message: 'Post not found' });
    }

    const comment = new ForumComment({
      postId,
      authorId: req.user.id,
      content,
    });

    await comment.save();
    await comment.populate('authorId', 'name avatar');

    req.io.emit('new_forum_comment', {
      postId,
      commentId: comment._id,
      message: 'New comment on post',
    });

    res.status(201).json({
      success: true,
      message: 'Comment added',
      data: comment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding comment',
      error: error.message,
    });
  }
};

exports.likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user.id;

    const post = await ForumPost.findById(postId);
    if (!post) {
      return res.status(404).json({ success: false, message: 'Post not found' });
    }

    const alreadyLiked = post.likes.find((l) => l.userId.toString() === userId);
    if (alreadyLiked) {
      // Unlike
      post.likes = post.likes.filter((l) => l.userId.toString() !== userId);
      post.likeCount = Math.max(0, post.likeCount - 1);
    } else {
      // Like
      post.likes.push({
        userId,
        createdAt: new Date(),
      });
      post.likeCount += 1;
    }

    await post.save();

    res.status(200).json({
      success: true,
      message: alreadyLiked ? 'Post unliked' : 'Post liked',
      data: post,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error liking post',
      error: error.message,
    });
  }
};

exports.likeComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.user.id;

    const comment = await ForumComment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ success: false, message: 'Comment not found' });
    }

    const alreadyLiked = comment.likes.find((l) => l.userId.toString() === userId);
    if (alreadyLiked) {
      comment.likes = comment.likes.filter((l) => l.userId.toString() !== userId);
      comment.likeCount = Math.max(0, comment.likeCount - 1);
    } else {
      comment.likes.push({
        userId,
        createdAt: new Date(),
      });
      comment.likeCount += 1;
    }

    await comment.save();

    res.status(200).json({
      success: true,
      message: alreadyLiked ? 'Comment unliked' : 'Comment liked',
      data: comment,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error liking comment',
      error: error.message,
    });
  }
};
