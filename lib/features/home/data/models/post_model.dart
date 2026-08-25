import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String content;
  final String? postImage;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    this.postImage,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.isLiked = false,
  });

  factory PostModel.fromFirestore(
    DocumentSnapshot doc, {
    bool isLiked = false,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      postImage: (data['postImage'] as String?)?.isNotEmpty == true
          ? data['postImage']
          : null,
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLiked: isLiked,
    );
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? content,
    String? postImage,
    int? likes,
    int? comments,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      postImage: postImage ?? this.postImage,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
