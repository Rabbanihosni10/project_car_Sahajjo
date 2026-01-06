import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/forum_service.dart';
import 'package:cars_ahajjo/models/forum_post.dart';

class CommunityPostDetailsScreen extends StatefulWidget {
  final String postId;

  const CommunityPostDetailsScreen({super.key, required this.postId});

  @override
  State<CommunityPostDetailsScreen> createState() =>
      _CommunityPostDetailsScreenState();
}

class _CommunityPostDetailsScreenState
    extends State<CommunityPostDetailsScreen> {
  ForumPost? _post;
  List<ForumComment> _comments = [];
  bool _loading = true;
  final _commentController = TextEditingController();
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetails() async {
    setState(() => _loading = true);
    final details = await ForumService.getPostDetails(widget.postId);
    if (details != null) {
      setState(() {
        _post = details['post'];
        _comments = details['comments'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _submittingComment = true);
    final success = await ForumService.addComment(
      widget.postId,
      _commentController.text.trim(),
    );

    if (success) {
      _commentController.clear();
      await _loadPostDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
      }
    }
    setState(() => _submittingComment = false);
  }

  Future<void> _likePost() async {
    if (_post == null) return;
    await ForumService.likePost(widget.postId);
    _loadPostDetails();
  }

  Future<void> _likeComment(String commentId) async {
    await ForumService.likeComment(commentId);
    _loadPostDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          if (_post != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuItem(value: 'report', child: Text('Report')),
              ],
              onSelected: (value) {
                // TODO: Handle actions
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
          ? const Center(child: Text('Post not found'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      _post!.authorName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _post!.authorName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          _formatDate(_post!.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_post!.isPinned)
                                    Icon(
                                      Icons.push_pin,
                                      color: Colors.red[400],
                                    ),
                                  if (_post!.isSolved)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[400],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Category badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    _post!.category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _post!.category.toUpperCase(),
                                  style: TextStyle(
                                    color: _getCategoryColor(_post!.category),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Title
                              Text(
                                _post!.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Content
                              Text(
                                _post!.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tags
                              if (_post!.tags.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _post!.tags.map((tag) {
                                    return Chip(
                                      label: Text('#$tag'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),

                              // Stats and actions
                              Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_post!.views}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 24),
                                  InkWell(
                                    onTap: _likePost,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _post!.isLikedByMe
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 18,
                                          color: _post!.isLikedByMe
                                              ? Colors.red
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_post!.likeCount}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Icon(
                                    Icons.comment,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_comments.length}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Divider(thickness: 8),

                        // Comments section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Comments (${_comments.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (_comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.comment_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            separatorBuilder: (context, index) =>
                                const Divider(indent: 16),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return _CommentCard(
                                comment: comment,
                                onLike: () => _likeComment(comment.id),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Comment input
                const Divider(height: 1),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _submittingComment ? null : _submitComment,
                        icon: _submittingComment
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
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

class _CommentCard extends StatelessWidget {
  final ForumComment comment;
  final VoidCallback onLike;

  const _CommentCard({required this.comment, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue[100],
                child: Text(
                  comment.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (comment.isAcceptedAnswer)
                Icon(Icons.check_circle, size: 20, color: Colors.green[600]),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: onLike,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  comment.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: comment.isLikedByMe ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${comment.likeCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
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
