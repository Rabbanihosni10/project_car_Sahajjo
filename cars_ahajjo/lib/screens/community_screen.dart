import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/forum_service.dart';
import 'package:cars_ahajjo/models/forum_post.dart';
import 'community_post_details_screen.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<ForumPost> _posts = [];
  bool _loading = true;
  String _selectedCategory = 'all';
  String _sortBy = 'newest';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'value': 'all', 'label': 'All', 'icon': Icons.grid_view},
    {'value': 'general', 'label': 'General', 'icon': Icons.forum},
    {'value': 'technical', 'label': 'Technical', 'icon': Icons.build},
    {
      'value': 'marketplace',
      'label': 'Marketplace',
      'icon': Icons.shopping_cart,
    },
    {'value': 'tips', 'label': 'Tips', 'icon': Icons.lightbulb},
    {'value': 'events', 'label': 'Events', 'icon': Icons.event},
    {
      'value': 'announcements',
      'label': 'Announcements',
      'icon': Icons.campaign,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final posts = await ForumService.getPosts(
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      sortBy: _sortBy,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Posts'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter keywords...',
            prefixIcon: Icon(Icons.search),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadPosts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Newest')),
              const PopupMenuItem(value: 'oldest', child: Text('Oldest')),
              const PopupMenuItem(value: 'popular', child: Text('Popular')),
              const PopupMenuItem(value: 'likes', child: Text('Most Liked')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search posts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search query display
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Searching for: "$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                    tooltip: 'Clear search',
                  ),
                ],
              ),
            ),
          // Category filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['value'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category['icon'] as IconData, size: 16),
                        const SizedBox(width: 4),
                        Text(category['label'] as String),
                      ],
                    ),
                    onSelected: (selected) {
                      setState(
                        () => _selectedCategory = category['value'] as String,
                      );
                      _loadPosts();
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Posts list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to start a discussion!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPosts,
                    child: ListView.separated(
                      itemCount: _posts.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return _PostCard(
                          post: post,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommunityPostDetailsScreen(postId: post.id),
                              ),
                            );
                            _loadPosts(); // Refresh after returning
                          },
                          onLike: () async {
                            await ForumService.likePost(post.id);
                            _loadPosts();
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
          _loadPosts();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onLike,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'technical':
        return Icons.build;
      case 'marketplace':
        return Icons.shopping_cart;
      case 'tips':
        return Icons.lightbulb;
      case 'events':
        return Icons.event;
      case 'announcements':
        return Icons.campaign;
      default:
        return Icons.forum;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'technical':
        return Colors.blue;
      case 'marketplace':
        return Colors.green;
      case 'tips':
        return Colors.orange;
      case 'events':
        return Colors.purple;
      case 'announcements':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author and metadata
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    post.authorName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  Icon(Icons.push_pin, size: 16, color: Colors.red[400]),
                if (post.isSolved)
                  Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Content preview
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),

            // Tags
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),

            // Footer: category, views, likes
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(post.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(post.category),
                        size: 14,
                        color: _getCategoryColor(post.category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getCategoryColor(post.category),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${post.views}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: onLike,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: post.isLikedByMe ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
