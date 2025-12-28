class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final List<String> images;
  final int likeCount;
  final int views;
  final bool isPinned;
  final bool isSolved;
  final bool isLikedByMe;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.images,
    required this.likeCount,
    required this.views,
    required this.isPinned,
    required this.isSolved,
    required this.isLikedByMe,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['_id'] ?? '',
      authorId: json['authorId']?['_id'] ?? json['authorId'] ?? '',
      authorName: json['authorId']?['name'] ?? 'Unknown',
      authorAvatar: json['authorId']?['avatar'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      likeCount: json['likeCount'] ?? 0,
      views: json['views'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      isSolved: json['isSolved'] ?? false,
      isLikedByMe: false, // Will be calculated from likes array
      status: json['status'] ?? 'published',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final int likeCount;
  final bool isAcceptedAnswer;
  final bool isLikedByMe;
  final DateTime createdAt;

  ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.likeCount,
    required this.isAcceptedAnswer,
    required this.isLikedByMe,
    required this.createdAt,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['_id'] ?? '',
      postId: json['postId'] ?? '',
      authorId: json['authorId']?['_id'] ?? json['authorId'] ?? '',
      authorName: json['authorId']?['name'] ?? 'Unknown',
      authorAvatar: json['authorId']?['avatar'],
      content: json['content'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      isAcceptedAnswer: json['isAcceptedAnswer'] ?? false,
      isLikedByMe: false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
