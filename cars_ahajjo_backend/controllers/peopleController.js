const Connection = require('../models/connection');
const UserProfile = require('../models/userProfile');
const User = require('../models/user');
const Message = require('../models/message');

/**
 * Get all users for people discovery
 * GET /api/people/discover
 */
exports.discoverPeople = async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 10, searchQuery = '' } = req.query;
    const skip = (page - 1) * limit;

    // Build search query
    let searchCondition = {
      _id: { $ne: userId }, // Exclude current user
      isActive: true,
      isVerified: true,
    };

    if (searchQuery) {
      searchCondition.$or = [
        { name: { $regex: searchQuery, $options: 'i' } },
        { email: { $regex: searchQuery, $options: 'i' } },
        { role: { $regex: searchQuery, $options: 'i' } },
      ];
    }

    // Get users
    const users = await User.find(searchCondition)
      .select('-password')
      .limit(limit)
      .skip(skip)
      .lean();

    // Get profiles for these users
    const userIds = users.map(u => u._id);
    const profiles = await UserProfile.find({ userId: { $in: userIds } }).lean();
    const profileMap = new Map(profiles.map(p => [p.userId.toString(), p]));

    // Get connection status for current user
    const connections = await Connection.find({
      $or: [
        { initiatorId: userId, recipientId: { $in: userIds } },
        { recipientId: userId, initiatorId: { $in: userIds } },
      ],
    }).lean();

    const connectionMap = new Map();
    connections.forEach(conn => {
      const key = [conn.initiatorId.toString(), conn.recipientId.toString()].sort().join('-');
      connectionMap.set(key, conn);
    });

    // Merge data and add connection status
    const peopleList = users.map(user => {
      const key = [userId, user._id.toString()].sort().join('-');
      const connection = connectionMap.get(key);
      const profile = profileMap.get(user._id.toString());

      return {
        ...user,
        profile: profile || {},
        connectionStatus: connection?.status || 'not_connected',
        connectionType: connection?.connectionType || null,
        isFollowing: connection?.isFollowing || false,
      };
    });

    res.json({
      success: true,
      message: 'People discovered successfully',
      data: peopleList,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: await User.countDocuments(searchCondition),
      },
    });
  } catch (error) {
    console.error('Error in discoverPeople:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to discover people',
      error: error.message,
    });
  }
};

/**
 * Get user profile
 * GET /api/people/profile/:userId
 */
exports.getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const currentUserId = req.user.id;

    // Get user
    const user = await User.findById(userId).select('-password').lean();
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Get profile
    const profile = await UserProfile.findOne({ userId }).lean() || {};

    // Get connection status
    const connection = await Connection.findOne({
      $or: [
        { initiatorId: currentUserId, recipientId: userId },
        { recipientId: currentUserId, initiatorId: userId },
      ],
    }).lean();

    // Get mutual friends
    const myConnections = await Connection.find({
      $or: [
        { initiatorId: currentUserId, status: 'accepted' },
        { recipientId: currentUserId, status: 'accepted' },
      ],
    }).select('initiatorId recipientId').lean();

    const myFriendIds = myConnections.map(c =>
      c.initiatorId.toString() === currentUserId ? c.recipientId : c.initiatorId
    );

    const userConnections = await Connection.find({
      $or: [
        { initiatorId: userId, status: 'accepted' },
        { recipientId: userId, status: 'accepted' },
      ],
    }).select('initiatorId recipientId').lean();

    const userFriendIds = userConnections.map(c =>
      c.initiatorId.toString() === userId ? c.recipientId : c.initiatorId
    );

    const mutualFriends = myFriendIds.filter(id =>
      userFriendIds.some(fid => fid.toString() === id.toString())
    );

    res.json({
      success: true,
      data: {
        user,
        profile,
        connectionStatus: connection?.status || 'not_connected',
        connectionType: connection?.connectionType || null,
        isFollowing: connection?.isFollowing || false,
        mutualFriendsCount: mutualFriends.length,
      },
    });
  } catch (error) {
    console.error('Error in getUserProfile:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile',
      error: error.message,
    });
  }
};

/**
 * Send connection request
 * POST /api/people/connect
 */
exports.sendConnectionRequest = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { recipientId, connectionType = 'friend' } = req.body;

    if (!recipientId) {
      return res.status(400).json({
        success: false,
        message: 'Recipient ID is required',
      });
    }

    if (currentUserId === recipientId) {
      return res.status(400).json({
        success: false,
        message: 'Cannot connect with yourself',
      });
    }

    // Check if connection already exists
    const existingConnection = await Connection.findOne({
      $or: [
        { initiatorId: currentUserId, recipientId },
        { recipientId: currentUserId, initiatorId: recipientId },
      ],
    });

    if (existingConnection) {
      return res.status(400).json({
        success: false,
        message: 'Connection already exists',
        connectionStatus: existingConnection.status,
      });
    }

    // Enforce driver↔owner-only connections
    const [initiatorUser, recipientUser] = await Promise.all([
      User.findById(currentUserId).select('role').lean(),
      User.findById(recipientId).select('role').lean(),
    ]);

    if (!initiatorUser || !recipientUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found for connection',
      });
    }

    const roles = new Set([initiatorUser.role, recipientUser.role]);
    if (!(roles.has('driver') && roles.has('owner'))) {
      return res.status(403).json({
        success: false,
        message: 'Connections are restricted to driver-owner pairs only',
      });
    }

    // Create new connection request
    const connection = new Connection({
      initiatorId: currentUserId,
      recipientId,
      connectionType,
      status: 'pending',
      requestedAt: new Date(),
    });

    await connection.save();

    res.json({
      success: true,
      message: 'Connection request sent successfully',
      data: connection,
    });
  } catch (error) {
    console.error('Error in sendConnectionRequest:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send connection request',
      error: error.message,
    });
  }
};

/**
 * Accept connection request
 * POST /api/people/accept-connection
 */
exports.acceptConnectionRequest = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { connectionId } = req.body;

    if (!connectionId) {
      return res.status(400).json({
        success: false,
        message: 'Connection ID is required',
      });
    }

    const connection = await Connection.findById(connectionId);

    if (!connection) {
      return res.status(404).json({
        success: false,
        message: 'Connection not found',
      });
    }

    if (connection.recipientId.toString() !== currentUserId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized: You cannot accept this request',
      });
    }

    // Enforce driver↔owner-only acceptance
    const [initiatorUser, recipientUser] = await Promise.all([
      User.findById(connection.initiatorId).select('role').lean(),
      User.findById(connection.recipientId).select('role').lean(),
    ]);

    const roles = new Set([initiatorUser?.role, recipientUser?.role]);
    if (!(roles.has('driver') && roles.has('owner'))) {
      return res.status(403).json({
        success: false,
        message: 'Only driver-owner pairs can be accepted as connections',
      });
    }

    connection.status = 'accepted';
    connection.acceptedAt = new Date();
    await connection.save();

    // Update profiles with friend/follower counts
    await updateConnectionCounts(connection.initiatorId, connection.recipientId);

    res.json({
      success: true,
      message: 'Connection accepted successfully',
      data: connection,
    });
  } catch (error) {
    console.error('Error in acceptConnectionRequest:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to accept connection request',
      error: error.message,
    });
  }
};

/**
 * Reject connection request
 * POST /api/people/reject-connection
 */
exports.rejectConnectionRequest = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { connectionId } = req.body;

    if (!connectionId) {
      return res.status(400).json({
        success: false,
        message: 'Connection ID is required',
      });
    }

    const connection = await Connection.findById(connectionId);

    if (!connection) {
      return res.status(404).json({
        success: false,
        message: 'Connection not found',
      });
    }

    if (connection.recipientId.toString() !== currentUserId) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized: You cannot reject this request',
      });
    }

    connection.status = 'rejected';
    await connection.save();

    res.json({
      success: true,
      message: 'Connection rejected successfully',
    });
  } catch (error) {
    console.error('Error in rejectConnectionRequest:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reject connection request',
      error: error.message,
    });
  }
};

/**
 * Follow/Unfollow user
 * POST /api/people/follow
 */
exports.toggleFollow = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    if (currentUserId === userId) {
      return res.status(400).json({
        success: false,
        message: 'Cannot follow yourself',
      });
    }

    let connection = await Connection.findOne({
      initiatorId: currentUserId,
      recipientId: userId,
    });

    if (!connection) {
      connection = new Connection({
        initiatorId: currentUserId,
        recipientId: userId,
        connectionType: 'follow',
        status: 'accepted',
        isFollowing: true,
      });
    } else {
      connection.isFollowing = !connection.isFollowing;
    }

    await connection.save();

    // Update follower counts
    const followerProfile = await UserProfile.findOne({ userId: currentUserId });
    const followingProfile = await UserProfile.findOne({ userId });

    if (connection.isFollowing) {
      if (followerProfile) {
        followerProfile.followingCount = (followerProfile.followingCount || 0) + 1;
        await followerProfile.save();
      }
      if (followingProfile) {
        followingProfile.followerCount = (followingProfile.followerCount || 0) + 1;
        await followingProfile.save();
      }
    } else {
      if (followerProfile) {
        followerProfile.followingCount = Math.max(0, (followerProfile.followingCount || 1) - 1);
        await followerProfile.save();
      }
      if (followingProfile) {
        followingProfile.followerCount = Math.max(0, (followingProfile.followerCount || 1) - 1);
        await followingProfile.save();
      }
    }

    res.json({
      success: true,
      message: connection.isFollowing ? 'Followed successfully' : 'Unfollowed successfully',
      data: { isFollowing: connection.isFollowing },
    });
  } catch (error) {
    console.error('Error in toggleFollow:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle follow status',
      error: error.message,
    });
  }
};

/**
 * Get friends list
 * GET /api/people/friends/:userId
 */
exports.getFriends = async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    const connections = await Connection.find({
      $or: [
        { initiatorId: userId, status: 'accepted', connectionType: { $ne: 'follow' } },
        { recipientId: userId, status: 'accepted', connectionType: { $ne: 'follow' } },
      ],
    })
      .populate('initiatorId', '-password')
      .populate('recipientId', '-password')
      .skip(skip)
      .limit(limit)
      .lean();

    const friends = connections.map(conn => {
      const friend = conn.initiatorId._id.toString() === userId ? conn.recipientId : conn.initiatorId;
      return friend;
    });

    const total = await Connection.countDocuments({
      $or: [
        { initiatorId: userId, status: 'accepted', connectionType: { $ne: 'follow' } },
        { recipientId: userId, status: 'accepted', connectionType: { $ne: 'follow' } },
      ],
    });

    res.json({
      success: true,
      data: friends,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
      },
    });
  } catch (error) {
    console.error('Error in getFriends:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get friends',
      error: error.message,
    });
  }
};

/**
 * Get followers
 * GET /api/people/followers/:userId
 */
exports.getFollowers = async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    const connections = await Connection.find({
      recipientId: userId,
      isFollowing: true,
      status: 'accepted',
    })
      .populate('initiatorId', '-password')
      .skip(skip)
      .limit(limit)
      .lean();

    const followers = connections.map(conn => conn.initiatorId);

    const total = await Connection.countDocuments({
      recipientId: userId,
      isFollowing: true,
      status: 'accepted',
    });

    res.json({
      success: true,
      data: followers,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
      },
    });
  } catch (error) {
    console.error('Error in getFollowers:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get followers',
      error: error.message,
    });
  }
};

/**
 * Get following list
 * GET /api/people/following/:userId
 */
exports.getFollowing = async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    const connections = await Connection.find({
      initiatorId: userId,
      isFollowing: true,
      status: 'accepted',
    })
      .populate('recipientId', '-password')
      .skip(skip)
      .limit(limit)
      .lean();

    const following = connections.map(conn => conn.recipientId);

    const total = await Connection.countDocuments({
      initiatorId: userId,
      isFollowing: true,
      status: 'accepted',
    });

    res.json({
      success: true,
      data: following,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
      },
    });
  } catch (error) {
    console.error('Error in getFollowing:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get following list',
      error: error.message,
    });
  }
};

/**
 * Get pending connection requests
 * GET /api/people/pending-requests
 */
exports.getPendingRequests = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { page = 1, limit = 10 } = req.query;
    const skip = (page - 1) * limit;

    const requests = await Connection.find({
      recipientId: currentUserId,
      status: 'pending',
    })
      .populate('initiatorId', '-password')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .lean();

    const total = await Connection.countDocuments({
      recipientId: currentUserId,
      status: 'pending',
    });

    res.json({
      success: true,
      data: requests,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
      },
    });
  } catch (error) {
    console.error('Error in getPendingRequests:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pending requests',
      error: error.message,
    });
  }
};

/**
 * Block user
 * POST /api/people/block
 */
exports.blockUser = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId, reason = '' } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    let connection = await Connection.findOne({
      $or: [
        { initiatorId: currentUserId, recipientId: userId },
        { recipientId: currentUserId, initiatorId: userId },
      ],
    });

    if (!connection) {
      connection = new Connection({
        initiatorId: currentUserId,
        recipientId: userId,
        status: 'blocked',
      });
    } else {
      connection.status = 'blocked';
    }

    connection.blockedAt = new Date();
    connection.blockedReason = reason;
    await connection.save();

    res.json({
      success: true,
      message: 'User blocked successfully',
      data: connection,
    });
  } catch (error) {
    console.error('Error in blockUser:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to block user',
      error: error.message,
    });
  }
};

/**
 * Unblock user
 * POST /api/people/unblock
 */
exports.unblockUser = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { userId } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    const connection = await Connection.findOne({
      $or: [
        { initiatorId: currentUserId, recipientId: userId },
        { recipientId: currentUserId, initiatorId: userId },
      ],
    });

    if (!connection) {
      return res.status(404).json({
        success: false,
        message: 'No block found for this user',
      });
    }

    await Connection.deleteOne({ _id: connection._id });

    res.json({
      success: true,
      message: 'User unblocked successfully',
    });
  } catch (error) {
    console.error('Error in unblockUser:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to unblock user',
      error: error.message,
    });
  }
};

/**
 * Get chat list with people
 * GET /api/people/chat-list
 */
exports.getChatList = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    // Get all unique users who have exchanged messages with current user
    const messages = await Message.find({
      $or: [
        { senderId: currentUserId },
        { receiverId: currentUserId },
      ],
    })
      .sort({ createdAt: -1 })
      .lean();

    // Get unique user IDs
    const userIdSet = new Set();
    messages.forEach(msg => {
      if (msg.senderId.toString() !== currentUserId) {
        userIdSet.add(msg.senderId.toString());
      }
      if (msg.receiverId.toString() !== currentUserId) {
        userIdSet.add(msg.receiverId.toString());
      }
    });

    const userIds = Array.from(userIdSet);

    // Get user details with their latest message
    const chatList = [];

    for (const userId of userIds) {
      const user = await User.findById(userId).select('-password role').lean();

      // Require accepted connection and driver↔owner roles
      const connection = await Connection.findOne({
        $or: [
          { initiatorId: currentUserId, recipientId: userId, status: 'accepted' },
          { recipientId: currentUserId, initiatorId: userId, status: 'accepted' },
        ],
      }).lean();

      const me = await User.findById(currentUserId).select('role').lean();
      const roles = new Set([me?.role, user?.role]);
      const rolesOk = roles.has('driver') && roles.has('owner');

      if (!connection || !rolesOk) {
        continue; // skip conversations that aren't allowed
      }

      const lastMessage = messages.find(
        msg =>
          (msg.senderId.toString() === currentUserId && msg.receiverId.toString() === userId) ||
          (msg.receiverId.toString() === currentUserId && msg.senderId.toString() === userId)
      );

      const unreadCount = await Message.countDocuments({
        senderId: userId,
        receiverId: currentUserId,
        isRead: false,
      });

      chatList.push({
        user,
        lastMessage,
        unreadCount,
        lastMessageTime: lastMessage?.createdAt,
      });
    }

    // Sort by last message time
    chatList.sort((a, b) => {
      const timeA = a.lastMessageTime ? new Date(a.lastMessageTime) : new Date(0);
      const timeB = b.lastMessageTime ? new Date(b.lastMessageTime) : new Date(0);
      return timeB - timeA;
    });

    const paginatedList = chatList.slice(skip, skip + parseInt(limit));

    res.json({
      success: true,
      data: paginatedList,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: userIds.length,
      },
    });
  } catch (error) {
    console.error('Error in getChatList:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get chat list',
      error: error.message,
    });
  }
};

/**
 * Get my accepted connections (people I can message)
 * GET /api/people/my-connections
 */
exports.getMyConnections = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const { page = 1, limit = 50 } = req.query;
    const skip = (page - 1) * limit;

    console.log(`📋 Getting connections for user: ${currentUserId}`);

    // Get current user's role
    const currentUser = await User.findById(currentUserId).select('role name').lean();
    if (!currentUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    console.log(`👤 Current user: ${currentUser.name} (${currentUser.role})`);

    // Find all accepted connections
    const connections = await Connection.find({
      $or: [
        { initiatorId: currentUserId, status: 'accepted' },
        { recipientId: currentUserId, status: 'accepted' },
      ],
    })
      .populate('initiatorId', 'name email phone role')
      .populate('recipientId', 'name email phone role')
      .sort({ acceptedAt: -1 })
      .lean();

    console.log(`🔗 Found ${connections.length} accepted connections`);

    // Filter for driver-owner pairs and extract the other user
    const messageable = [];
    for (const conn of connections) {
      const otherUser = conn.initiatorId._id.toString() === currentUserId
        ? conn.recipientId
        : conn.initiatorId;

      const roles = new Set([currentUser.role, otherUser.role]);
      const isDriverOwnerPair = roles.has('driver') && roles.has('owner');

      if (isDriverOwnerPair) {
        // Get last message if exists
        const lastMessage = await Message.findOne({
          $or: [
            { senderId: currentUserId, receiverId: otherUser._id },
            { senderId: otherUser._id, receiverId: currentUserId },
          ],
        })
          .sort({ createdAt: -1 })
          .lean();

        // Count unread messages
        const unreadCount = await Message.countDocuments({
          senderId: otherUser._id,
          receiverId: currentUserId,
          isRead: false,
        });

        messageable.push({
          user: otherUser,
          connectionId: conn._id,
          connectionStatus: conn.status,
          lastMessage: lastMessage ? lastMessage.message : null,
          lastMessageTime: lastMessage ? lastMessage.createdAt : conn.acceptedAt,
          unreadCount,
          canMessage: true,
        });
      }
    }

    console.log(`✅ ${messageable.length} messageable connections (driver-owner pairs)`);

    // Sort by last activity
    messageable.sort((a, b) => {
      const timeA = new Date(a.lastMessageTime);
      const timeB = new Date(b.lastMessageTime);
      return timeB - timeA;
    });

    const paginatedList = messageable.slice(skip, skip + parseInt(limit));

    res.json({
      success: true,
      data: paginatedList,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: messageable.length,
      },
    });
  } catch (error) {
    console.error('❌ Error in getMyConnections:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get connections',
      error: error.message,
    });
  }
};

/**
 * Update user profile
 * PUT /api/people/profile
 */
exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const updateData = req.body;

    // Fields that are allowed to be updated
    const allowedFields = [
      'bio',
      'avatar',
      'coverImage',
      'location',
      'profession',
      'website',
      'dateOfBirth',
      'gender',
      'interests',
      'isProfilePublic',
      'allowDirectMessages',
      'allowConnectionRequests',
      'socialLinks',
    ];

    // Filter only allowed fields
    const filteredData = {};
    allowedFields.forEach(field => {
      if (updateData.hasOwnProperty(field)) {
        filteredData[field] = updateData[field];
      }
    });

    let profile = await UserProfile.findOne({ userId });

    if (!profile) {
      filteredData.userId = userId;
      profile = new UserProfile(filteredData);
    } else {
      Object.assign(profile, filteredData);
    }

    await profile.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: profile,
    });
  } catch (error) {
    console.error('Error in updateProfile:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: error.message,
    });
  }
};

// Helper function to update connection counts
async function updateConnectionCounts(initiatorId, recipientId) {
  try {
    const initiatorProfile = await UserProfile.findOne({ userId: initiatorId });
    const recipientProfile = await UserProfile.findOne({ userId: recipientId });

    if (initiatorProfile) {
      initiatorProfile.friendCount = (initiatorProfile.friendCount || 0) + 1;
      await initiatorProfile.save();
    }

    if (recipientProfile) {
      recipientProfile.friendCount = (recipientProfile.friendCount || 0) + 1;
      await recipientProfile.save();
    }
  } catch (error) {
    console.error('Error updating connection counts:', error);
  }
}
