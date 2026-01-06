import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/message_service.dart';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> otherUser;
  final Map<String, dynamic>? currentUser;

  const ChatScreen({super.key, required this.otherUser, this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _conversationId;
  String? _currentUserId;
  Set<String> _typingUsers = {};

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _initializeSocket();
  }

  /// Initialize Socket.io for real-time messaging
  void _initializeSocket() async {
    _currentUserId = await AuthService.getUserId();
    _conversationId = widget.otherUser['_id'];

    MessageService.initializeSocket();
    if (_conversationId != null) {
      MessageService.joinConversation(_conversationId!);
    }

    // Listen for incoming messages
    MessageService.onMessageReceived((data) {
      print('Message received: $data');
      if (mounted) {
        setState(() {
          messages.insert(0, data);
        });
      }
    });

    // Listen for typing indicators
    MessageService.onUserTyping((data) {
      final userId = data['userId'];
      final isTyping = data['isTyping'] ?? false;

      if (mounted) {
        setState(() {
          if (isTyping) {
            _typingUsers.add(userId);
          } else {
            _typingUsers.remove(userId);
          }
        });
      }
    });
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatHistory = await MessageService.getChatHistory(
        widget.otherUser['_id'],
      );

      // Mark as read
      await MessageService.markAsRead(widget.otherUser['_id']);

      setState(() {
        messages = chatHistory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot connect to chat server. Please ensure backend is running at http://localhost:5003',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    setState(() => _isSending = true);

    // Stop typing indicator
    if (_conversationId != null && _currentUserId != null) {
      MessageService.notifyStopTyping(_conversationId!, _currentUserId!);
    }

    final success = await MessageService.sendMessage(
      widget.otherUser['_id'],
      messageText,
    );

    if (success) {
      // Send via Socket.io for real-time delivery
      if (_conversationId != null && _currentUserId != null) {
        MessageService.sendChatMessageRealtime(
          _currentUserId!,
          _conversationId!,
          messageText,
          _conversationId!,
        );
      }

      // Reload chat history
      await _loadChatHistory();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to send message. Please ensure backend server is running.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() => _isSending = false);
  }

  String _formatTime(String dateString) {
    final dateTime = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUser['name'] ?? 'Chat',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              widget.otherUser['phone'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isSender =
                          widget.currentUser != null &&
                          message['senderId']['_id'] ==
                              widget.currentUser!['_id'];

                      return _buildMessageBubble(message, isSender);
                    },
                  ),
          ),
          // Typing indicator
          if (_typingUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey[100],
              child: Text(
                '${_typingUsers.length} user${_typingUsers.length > 1 ? 's' : ''} typing...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          // Message input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      // Notify others that user is typing
                      if (value.isNotEmpty &&
                          _conversationId != null &&
                          _currentUserId != null) {
                        MessageService.notifyTyping(
                          _conversationId!,
                          _currentUserId!,
                        );
                      } else if (value.isEmpty &&
                          _conversationId != null &&
                          _currentUserId != null) {
                        MessageService.notifyStopTyping(
                          _conversationId!,
                          _currentUserId!,
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.blue[600]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.blue[600],
                  onPressed: _isSending ? null : _sendMessage,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, bool isSender) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isSender)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[200],
              child: Text(
                (message['senderId']['name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: isSender ? Colors.blue[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: isSender
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message['message'] ?? '',
                  style: TextStyle(
                    color: isSender ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message['createdAt']),
                  style: TextStyle(
                    color: isSender ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isSender)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[600],
              child: const Text(
                'Y',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    if (_conversationId != null) {
      MessageService.leaveConversation(_conversationId!);
    }
    MessageService.disconnectSocket();
    super.dispose();
  }
}
