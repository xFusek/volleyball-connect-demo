import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String content;
  final String? postImage;
  final int likes;
  final int comments;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.content,
    this.postImage,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      postImage: data['postImage'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'content': content,
      'postImage': postImage,
      'likes': likes,
      'comments': comments,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
