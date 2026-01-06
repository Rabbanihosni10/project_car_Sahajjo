import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/forum_service.dart';
import 'package:cars_ahajjo/models/forum_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ForumScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ForumScreen({super.key, required this.userData});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  late Future<List<ForumPost>> _forumPostsFuture;
  String _selectedCategory = 'general';
  List<ForumPost> _posts = [];
  bool _shownPostHint = false;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic> _currentUserData = {};
  String _searchQuery = '';

  bool get _canPost {
    // Use loaded user data if widget.userData is empty
    final userData = widget.userData.isEmpty
        ? _currentUserData
        : widget.userData;

    // If userData is empty or null, user is not logged in
    if (userData.isEmpty) {
      print('Forum: userData is empty, user not logged in');
      return false;
    }

    final role = userData['role'] as String?;
    final roleLower = role?.toLowerCase();

    // Debug logging
    print('Forum: Checking role: "$role" (lowercase: "$roleLower")');
    print('Forum: userData keys: ${userData.keys.toList()}');

    // If no role found but user is logged in (has userData), check if they're a visitor
    if (role == null || role.isEmpty) {
      print('Forum: No role field found');
      // If they have userData but no role, they might be visitor - deny posting
      final hasEmail = userData['email'] != null;
      return hasEmail; // Allow if they have email (logged in)
    }

    // Check various role formats (case-insensitive)
    final canPost =
        roleLower == 'driver' ||
        roleLower == 'owner' ||
        roleLower == 'carowner' ||
        roleLower == 'car owner';

    print('Forum: Can post? $canPost');
    return canPost;
  }

  final List<String> _categories = [
    'general',
    'technical',
    'marketplace',
    'tips',
    'events',
    'announcements',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPosts();
    // Show one-time hint if user arrived from sign-in intent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final showHint = widget.userData['showPostHint'] == true;
      if (showHint && _canPost && !_shownPostHint) {
        _checkAndShowPostHint();
      }
    });
  }

  Future<void> _loadUserData() async {
    // If widget.userData is empty, try to load from SharedPreferences
    if (widget.userData.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        final userEmail = prefs.getString('userEmail');
        final userName = prefs.getString('userName');
        final userRole = prefs.getString('userRole');

        if (userId != null && userRole != null) {
          setState(() {
            _currentUserData = {
              'id': userId,
              'email': userEmail,
              'name': userName,
              'role': userRole,
            };
          });
          print(
            'Forum: Loaded user data from SharedPreferences: $_currentUserData',
          );
        } else {
          print('Forum: No user data found in SharedPreferences');
        }
      } catch (e) {
        print('Forum: Error loading user data: $e');
      }
    } else {
      _currentUserData = widget.userData;
      print('Forum: Using userData from widget: $_currentUserData');
    }
  }

  Future<void> _checkAndShowPostHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hidden = prefs.getBool('hideForumPostHint') ?? false;
    if (hidden) return;
    _shownPostHint = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You can post now. Share your update!'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Don\'t show again',
          onPressed: () async {
            await prefs.setBool('hideForumPostHint', true);
          },
        ),
      ),
    );
  }

  void _loadPosts() {
    _forumPostsFuture = ForumService.getPosts(
      category: _selectedCategory == 'general' ? null : _selectedCategory,
    );

    // Also load directly for real-time updates
    _refreshPostsList();
  }

  Future<void> _refreshPostsList() async {
    try {
      final posts = await ForumService.getPosts(
        category: _selectedCategory == 'general' ? null : _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
        });
      }
    } catch (e) {
      print('Error refreshing posts: $e');
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Posts'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title, content, or tags...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSearch(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles
              .map((xFile) => File(xFile.path))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _clearAllImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  Future<void> _createPost() async {
    if (!_canPost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only drivers and owners can post to the forum.'),
        ),
      );
      return;
    }
    if (_titleController.text.isEmpty || _postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ForumService.createPost(
        title: _titleController.text,
        content: _postController.text,
        category: _selectedCategory,
        tags: [],
        images: _selectedImages,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result != null) {
          _titleController.clear();
          _postController.clear();
          _clearAllImages();

          // Add the new post to the list immediately for real-time display
          setState(() {
            _posts.insert(0, result);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully!'),
              duration: Duration(seconds: 2),
            ),
          );

          // Refresh the list to sync with server
          _loadPosts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create post'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
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
          'Community Forum',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search posts',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadPosts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing posts...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadPosts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Create Post Section
              _buildCreatePostWidget(),
              const SizedBox(height: 12),

              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _loadPosts();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF2196F3),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Forum Posts - Display from local list first
              _buildPostsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    if (_posts.isEmpty) {
      return FutureBuilder<List<ForumPost>>(
        future: _forumPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error loading posts: ${snapshot.error}'),
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.forum, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text(
                      'No posts yet. Be the first to post!',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildForumPost(posts[index]);
            },
          );
        },
      );
    }

    // Show local posts list
    if (_posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.forum, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 10),
              Text(
                'No posts yet. Be the first to post!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildForumPost(_posts[index]);
      },
    );
  }

  Widget _buildCreatePostWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_canPost)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF57C00)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Only drivers and owners can create posts. Sign in with an eligible account to participate.',
                      style: TextStyle(color: Color(0xFF6D4C41)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signin');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Color(0xFFF57C00),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[400],
                radius: 24,
                child: Text(
                  widget.userData['name']?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      enabled: !_isLoading && _canPost,
                      decoration: InputDecoration(
                        hintText: 'Post title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _postController,
                      enabled: !_isLoading && _canPost,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: _isLoading || !_canPost
                          ? null
                          : (value) {
                              setState(
                                () => _selectedCategory = value ?? 'General',
                              );
                            },
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    // Image selection buttons
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isLoading || !_canPost
                              ? null
                              : _pickImages,
                          icon: const Icon(Icons.image),
                          label: const Text('Add Images'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedImages.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _clearAllImages,
                            icon: const Icon(Icons.clear),
                            label: Text('Clear (${_selectedImages.length})'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    // Image preview grid
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || !_canPost ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumPost(ForumPost post) {
    final firstLetter = post.authorName.isNotEmpty ? post.authorName[0] : 'U';
    final createdAt = post.createdAt;
    final daysDiff = DateTime.now().difference(createdAt).inDays;
    final dateStr = daysDiff == 0
        ? 'Today'
        : daysDiff == 1
        ? 'Yesterday'
        : '$daysDiff days ago';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[400],
                  radius: 20,
                  child: Text(
                    firstLetter.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post content
            Text(
              post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            // Display images if available
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: post.images.map((imageUrl) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(imageUrl.split(',')[1]),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imageUrl,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  );
                                },
                              ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Engagement buttons
            Row(
              children: [
                _buildEngagementButton(
                  icon: Icons.favorite_border,
                  label: '${post.likeCount} likes',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liked!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _buildEngagementButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${post.views} replies',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Replies feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _buildEngagementButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
