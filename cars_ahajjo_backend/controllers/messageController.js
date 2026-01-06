const Message = require('../models/message');
const User = require('../models/user');
const Connection = require('../models/connection');

// Helper: ensure messaging allowed only between driver↔owner with accepted connection
async function isMessagingAllowed(userIdA, userIdB) {
  console.log(`🔍 Checking messaging permission between ${userIdA} and ${userIdB}`);
  
  const [userA, userB] = await Promise.all([
    User.findById(userIdA).select('role').lean(),
    User.findById(userIdB).select('role').lean(),
  ]);
  
  if (!userA || !userB) {
    console.log('❌ One or both users not found');
    return false;
  }
  
  console.log(`👤 User A role: ${userA.role}, User B role: ${userB.role}`);
  
  const roles = new Set([userA.role, userB.role]);
  if (!(roles.has('driver') && roles.has('owner'))) {
    console.log('❌ Not a driver-owner pair');
    return false;
  }

  const connection = await Connection.findOne({
    $or: [
      { initiatorId: userIdA, recipientId: userIdB, status: 'accepted' },
      { recipientId: userIdA, initiatorId: userIdB, status: 'accepted' },
    ],
  }).lean();
  
  if (!connection) {
    console.log('❌ No accepted connection found');
    console.log('💡 TIP: Users must accept connection request before messaging');
    return false;
  }
  
  console.log('✅ Messaging allowed - Connection exists:', connection._id);
  return true;
}

// Get all conversations for a user
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get all unique users this user has messaged
    const messages = await Message.find({
      $or: [{ senderId: userId }, { receiverId: userId }],
    })
      .populate('senderId', 'name email phone')
      .populate('receiverId', 'name email phone')
      .sort({ createdAt: -1 });

    // Group by conversation partner, but only include allowed driver↔owner pairs
    const conversations = {};
    for (const msg of messages) {
      const partner = msg.senderId._id.toString() === userId.toString()
        ? msg.receiverId
        : msg.senderId;
      const partnerId = partner._id.toString();

      // Role + accepted connection check
      const allowed = await isMessagingAllowed(userId, partnerId);
      if (!allowed) continue;

      if (!conversations[partnerId]) {
        conversations[partnerId] = {
          user: partner,
          lastMessage: msg.message,
          lastMessageTime: msg.createdAt,
          unreadCount: msg.isRead ? 0 : 1,
        };
      } else if (!msg.isRead && msg.receiverId.toString() === userId.toString()) {
        conversations[partnerId].unreadCount += 1;
      }
    }

    res.status(200).json({
      success: true,
      data: Object.values(conversations),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching conversations',
      error: error.message,
    });
  }
};

// Get chat history between two users
exports.getChatHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { otherUserId } = req.params;

    const allowed = await isMessagingAllowed(userId, otherUserId);
    if (!allowed) {
      return res.status(403).json({
        success: false,
        message: 'Messaging permitted only between driver and their owner with an accepted connection',
      });
    }

    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: userId },
      ],
      deletedBySender: { $ne: true },
      deletedByReceiver: { $ne: true },
    })
      .populate('senderId', 'name email phone')
      .populate('receiverId', 'name email phone')
      .sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      {
        senderId: otherUserId,
        receiverId: userId,
        isRead: false,
      },
      {
        isRead: true,
        readAt: new Date(),
      }
    );

    res.status(200).json({
      success: true,
      data: messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching chat history',
      error: error.message,
    });
  }
};

// Send a message
exports.sendMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { receiverId, message, messageType } = req.body;

    console.log(`📤 Send message request from ${userId} to ${receiverId}`);

    if (!receiverId || !message) {
      return res.status(400).json({
        success: false,
        message: 'Receiver ID and message are required',
      });
    }

    // Verify receiver exists
    const receiver = await User.findById(receiverId).select('role name');
    if (!receiver) {
      return res.status(404).json({
        success: false,
        message: 'Receiver not found',
      });
    }

    const sender = await User.findById(userId).select('role name');
    console.log(`Sender: ${sender.name} (${sender.role}) → Receiver: ${receiver.name} (${receiver.role})`);

    // Role + accepted connection check
    const allowed = await isMessagingAllowed(userId, receiverId);
    if (!allowed) {
      // Check what the specific issue is
      const senderRole = sender.role;
      const receiverRole = receiver.role;
      
      let detailedMessage = '';
      const roles = new Set([senderRole, receiverRole]);
      
      if (!(roles.has('driver') && roles.has('owner'))) {
        detailedMessage = `Messaging requires a driver-owner pair. Current: ${senderRole} → ${receiverRole}`;
      } else {
        // Role is correct, so connection must be missing
        const connection = await Connection.findOne({
          $or: [
            { initiatorId: userId, recipientId: receiverId },
            { recipientId: userId, initiatorId: receiverId },
          ],
        });
        
        if (!connection) {
          detailedMessage = 'No connection request exists. Please send a connection request first.';
        } else if (connection.status === 'pending') {
          detailedMessage = 'Connection request is pending. Please wait for acceptance.';
        } else if (connection.status === 'rejected') {
          detailedMessage = 'Connection request was rejected.';
        } else if (connection.status === 'blocked') {
          detailedMessage = 'One user has blocked the other.';
        } else {
          detailedMessage = `Connection exists but status is: ${connection.status}`;
        }
      }
      
      return res.status(403).json({
        success: false,
        message: 'Messaging not allowed',
        details: detailedMessage,
      });
    }

    const newMessage = new Message({
      senderId: userId,
      receiverId,
      message,
      messageType: messageType || 'text',
    });

    await newMessage.save();
    await newMessage.populate('senderId', 'name email phone');
    await newMessage.populate('receiverId', 'name email phone');

    console.log('✅ Message sent successfully');

    res.status(201).json({
      success: true,
      message: 'Message sent successfully',
      data: newMessage,
    });
  } catch (error) {
    console.error('❌ Error sending message:', error);
    res.status(500).json({
      success: false,
      message: 'Error sending message',
      error: error.message,
    });
  }
};

// Delete message (soft delete)
exports.deleteMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const { messageId } = req.params;

    const message = await Message.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found',
      });
    }

    // Check if user is sender
    if (message.senderId.toString() === userId.toString()) {
      message.deletedBySender = true;
    }
    // Check if user is receiver
    else if (message.receiverId.toString() === userId.toString()) {
      message.deletedByReceiver = true;
    } else {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own messages',
      });
    }

    await message.save();

    res.status(200).json({
      success: true,
      message: 'Message deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting message',
      error: error.message,
    });
  }
};

// Mark messages as read
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const { otherUserId } = req.body;

    await Message.updateMany(
      {
        senderId: otherUserId,
        receiverId: userId,
        isRead: false,
      },
      {
        isRead: true,
        readAt: new Date(),
      }
    );

    res.status(200).json({
      success: true,
      message: 'Messages marked as read',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error marking messages as read',
      error: error.message,
    });
  }
};

// Get or create a conversation with a user
exports.getOrCreateConversation = async (req, res) => {
  try {
    const userId = req.user.id;
    const { otherUserId } = req.body;

    if (!otherUserId) {
      return res.status(400).json({
        success: false,
        message: 'otherUserId is required',
      });
    }

    // Check if conversation exists between these two users
    const existingMessages = await Message.findOne({
      $or: [
        { senderId: userId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: userId },
      ],
    })
      .populate('senderId', 'name email phone role')
      .populate('receiverId', 'name email phone role')
      .sort({ createdAt: -1 });

    // If conversation exists, return it (allowed pairs only)
    if (existingMessages) {
      const allowed = await isMessagingAllowed(userId, otherUserId);
      if (!allowed) {
        return res.status(403).json({
          success: false,
          message: 'Conversations are restricted to driver-owner pairs with accepted connection',
        });
      }
      return res.status(200).json({
        success: true,
        data: {
          _id: existingMessages._id,
          participants: [existingMessages.senderId, existingMessages.receiverId],
          lastMessage: existingMessages.message,
          lastMessageTime: existingMessages.createdAt,
        },
      });
    }

    // Otherwise, return conversation metadata (will be created on first message)
    const otherUser = await User.findById(otherUserId).select(
      'name email phone role'
    );

    if (!otherUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Only allow conversation metadata creation if the pair is allowed
    const allowed = await isMessagingAllowed(userId, otherUserId);
    if (!allowed) {
      return res.status(403).json({
        success: false,
        message: 'Only driver-owner pairs with accepted connection can start conversations',
      });
    }

    res.status(201).json({
      success: true,
      data: {
        participants: [
          { _id: userId },
          { _id: otherUserId, ...otherUser.toObject() },
        ],
        lastMessage: null,
        lastMessageTime: new Date(),
      },
    });
  } catch (error) {
    console.error('Error in getOrCreateConversation:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating conversation',
      error: error.message,
    });
  }
};
