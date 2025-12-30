import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/forum_post.dart';

class LocalForumDatabase {
  static final LocalForumDatabase _instance = LocalForumDatabase._internal();

  factory LocalForumDatabase() {
    return _instance;
  }

  LocalForumDatabase._internal();

  static Database? _database;
  final List<ForumPost> _memoryPosts = <ForumPost>[];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'forum_posts.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE forum_posts (
        id TEXT PRIMARY KEY,
        authorId TEXT NOT NULL,
        authorName TEXT NOT NULL,
        authorAvatar TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT DEFAULT '[]',
        images TEXT DEFAULT '[]',
        likeCount INTEGER DEFAULT 0,
        views INTEGER DEFAULT 0,
        isPinned INTEGER DEFAULT 0,
        isSolved INTEGER DEFAULT 0,
        isLikedByMe INTEGER DEFAULT 0,
        status TEXT DEFAULT 'published',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isSyncedWithServer INTEGER DEFAULT 0
      )
    ''');
  }

  // Create/Insert post
  Future<int> insertPost(ForumPost post) async {
    if (kIsWeb) {
      _memoryPosts.removeWhere((p) => p.id == post.id);
      _memoryPosts.add(post);
      return 1;
    }
    final db = await database;
    return await db.insert('forum_posts', {
      'id': post.id,
      'authorId': post.authorId,
      'authorName': post.authorName,
      'authorAvatar': post.authorAvatar,
      'title': post.title,
      'content': post.content,
      'category': post.category,
      'tags': post.tags.join(','),
      'images': post.images.join(','),
      'likeCount': post.likeCount,
      'views': post.views,
      'isPinned': post.isPinned ? 1 : 0,
      'isSolved': post.isSolved ? 1 : 0,
      'isLikedByMe': post.isLikedByMe ? 1 : 0,
      'status': post.status,
      'createdAt': post.createdAt.toIso8601String(),
      'updatedAt': post.updatedAt.toIso8601String(),
      'isSyncedWithServer': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all posts from database
  Future<List<ForumPost>> getAllPosts({String? category}) async {
    if (kIsWeb) {
      final list = List<ForumPost>.from(_memoryPosts);
      if (category != null && category.isNotEmpty) {
        final filtered = list.where((p) => p.category == category).toList();
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return filtered;
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    final db = await database;
    List<Map<String, dynamic>> maps;

    if (category != null && category.isNotEmpty) {
      maps = await db.query(
        'forum_posts',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );
    } else {
      maps = await db.query('forum_posts', orderBy: 'createdAt DESC');
    }

    return List.generate(maps.length, (i) {
      final m = maps[i];
      return ForumPost(
        id: (m['id'] as String?) ?? '',
        authorId: (m['authorId'] as String?) ?? '',
        authorName: (m['authorName'] as String?) ?? 'Unknown',
        authorAvatar: m['authorAvatar'] as String?,
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'general',
        tags: ((m['tags'] as String?)?.split(',').toList()) ?? [],
        images: ((m['images'] as String?)?.split(',').toList()) ?? [],
        likeCount: (m['likeCount'] as int?) ?? 0,
        views: (m['views'] as int?) ?? 0,
        isPinned: ((m['isPinned'] as int?) ?? 0) == 1,
        isSolved: ((m['isSolved'] as int?) ?? 0) == 1,
        isLikedByMe: ((m['isLikedByMe'] as int?) ?? 0) == 1,
        status: (m['status'] as String?) ?? 'published',
        createdAt: DateTime.parse(
          (m['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          (m['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
      );
    });
  }

  // Get single post
  Future<ForumPost?> getPost(String postId) async {
    if (kIsWeb) {
      try {
        return _memoryPosts.firstWhere((p) => p.id == postId);
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final maps = await db.query(
      'forum_posts',
      where: 'id = ?',
      whereArgs: [postId],
    );

    if (maps.isNotEmpty) {
      final m = maps.first;
      return ForumPost(
        id: (m['id'] as String?) ?? '',
        authorId: (m['authorId'] as String?) ?? '',
        authorName: (m['authorName'] as String?) ?? 'Unknown',
        authorAvatar: m['authorAvatar'] as String?,
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'general',
        tags: ((m['tags'] as String?)?.split(',').toList()) ?? [],
        images: ((m['images'] as String?)?.split(',').toList()) ?? [],
        likeCount: (m['likeCount'] as int?) ?? 0,
        views: (m['views'] as int?) ?? 0,
        isPinned: ((m['isPinned'] as int?) ?? 0) == 1,
        isSolved: ((m['isSolved'] as int?) ?? 0) == 1,
        isLikedByMe: ((m['isLikedByMe'] as int?) ?? 0) == 1,
        status: (m['status'] as String?) ?? 'published',
        createdAt: DateTime.parse(
          (m['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          (m['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
      );
    }
    return null;
  }

  // Update post
  Future<int> updatePost(ForumPost post) async {
    if (kIsWeb) {
      final idx = _memoryPosts.indexWhere((p) => p.id == post.id);
      if (idx >= 0) {
        _memoryPosts[idx] = post;
        return 1;
      }
      return 0;
    }

    final db = await database;
    return await db.update(
      'forum_posts',
      {
        'title': post.title,
        'content': post.content,
        'category': post.category,
        'tags': post.tags.join(','),
        'images': post.images.join(','),
        'likeCount': post.likeCount,
        'views': post.views,
        'isPinned': post.isPinned ? 1 : 0,
        'isSolved': post.isSolved ? 1 : 0,
        'status': post.status,
        'updatedAt': post.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // Delete post
  Future<int> deletePost(String postId) async {
    if (kIsWeb) {
      final before = _memoryPosts.length;
      _memoryPosts.removeWhere((p) => p.id == postId);
      final after = _memoryPosts.length;
      return before - after;
    }

    final db = await database;
    return await db.delete('forum_posts', where: 'id = ?', whereArgs: [postId]);
  }

  // Get unsynced posts
  Future<List<ForumPost>> getUnsyncedPosts() async {
    if (kIsWeb) {
      return [];
    }

    final db = await database;
    final maps = await db.query('forum_posts', where: 'isSyncedWithServer = 0');

    return List.generate(maps.length, (i) {
      final m = maps[i];
      return ForumPost(
        id: (m['id'] as String?) ?? '',
        authorId: (m['authorId'] as String?) ?? '',
        authorName: (m['authorName'] as String?) ?? 'Unknown',
        authorAvatar: m['authorAvatar'] as String?,
        title: (m['title'] as String?) ?? '',
        content: (m['content'] as String?) ?? '',
        category: (m['category'] as String?) ?? 'general',
        tags: ((m['tags'] as String?)?.split(',').toList()) ?? [],
        images: ((m['images'] as String?)?.split(',').toList()) ?? [],
        likeCount: (m['likeCount'] as int?) ?? 0,
        views: (m['views'] as int?) ?? 0,
        isPinned: ((m['isPinned'] as int?) ?? 0) == 1,
        isSolved: ((m['isSolved'] as int?) ?? 0) == 1,
        isLikedByMe: ((m['isLikedByMe'] as int?) ?? 0) == 1,
        status: (m['status'] as String?) ?? 'published',
        createdAt: DateTime.parse(
          (m['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          (m['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
        ),
      );
    });
  }

  // Mark post as synced
  Future<int> markPostAsSynced(String postId) async {
    if (kIsWeb) {
      return 1;
    }

    final db = await database;
    return await db.update(
      'forum_posts',
      {'isSyncedWithServer': 1},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  // Clear all posts
  Future<int> clearAllPosts() async {
    if (kIsWeb) {
      final count = _memoryPosts.length;
      _memoryPosts.clear();
      return count;
    }

    final db = await database;
    return await db.delete('forum_posts');
  }

  // Close database
  Future<void> closeDatabase() async {
    if (kIsWeb) {
      return;
    }
    final db = await database;
    await db.close();
  }
}
