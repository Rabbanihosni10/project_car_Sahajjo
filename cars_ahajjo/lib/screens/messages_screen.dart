import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/message_service.dart';
import 'package:cars_ahajjo/screens/users_list_screen.dart';

class MessagesScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MessagesScreen({super.key, required this.userData});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late Future<List<dynamic>> _conversationsFuture;
  final TextEditingController _messageController = TextEditingController();
  String? _selectedConversationId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    _conversationsFuture = MessageService.getConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a message')));
      return;
    }

    if (_selectedConversationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a conversation')),
      );
      return;
    }

    final success = await MessageService.sendMessage(
      _selectedConversationId!,
      _messageController.text,
    );

    if (mounted) {
      if (success) {
        _messageController.clear();
        _loadConversations();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Message sent!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UsersListScreen(),
                ),
              ).then((_) {
                // Refresh conversations when returning
                setState(() {
                  _loadConversations();
                });
              });
            },
            tooltip: 'Start New Chat',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UsersListScreen()),
          ).then((_) {
            // Refresh conversations when returning
            setState(() {
              _loadConversations();
            });
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
        tooltip: 'New Chat',
      ),
      body: Column(
        children: [
          // Conversations list
          Expanded(
            flex: 1,
            child: FutureBuilder<List<dynamic>>(
              future: _conversationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final conversations = snapshot.data ?? [];

                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UsersListScreen(),
                              ),
                            ).then((_) {
                              setState(() {
                                _loadConversations();
                              });
                            });
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Find Users to Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final id = conv['_id'] ?? conv['id'];
                    final participantName =
                        conv['participantName'] ??
                        conv['otherUser']?['name'] ??
                        'Unknown';
                    final lastMessage =
                        conv['lastMessage'] ?? 'No messages yet';
                    final isSelected = id == _selectedConversationId;

                    return Container(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      child: ListTile(
                        onTap: () {
                          setState(() => _selectedConversationId = id);
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[400],
                          child: Text(
                            participantName.isNotEmpty
                                ? participantName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(participantName),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? Container(width: 4, color: Colors.blue)
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedConversationId == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Select a conversation to start messaging',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: _selectedConversationId != null,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _selectedConversationId != null
                          ? _sendMessage
                          : null,
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
