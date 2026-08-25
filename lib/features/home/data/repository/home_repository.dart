import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};

    return UserModel(
      id: user.uid,
      name: data['name'] ?? 'Unknown',
      handle: data['handle'] ?? '@unknown',
      avatarUrl: data['image'] ?? '',
    );
  }

  Future<List<PostModel>> fetchPosts() async {
    final currentUserId = _auth.currentUser?.uid;

    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    final posts = await Future.wait(
      snapshot.docs.map((doc) async {
        bool isLiked = false;
        if (currentUserId != null) {
          final likeDoc = await _firestore
              .collection('posts')
              .doc(doc.id)
              .collection('likes')
              .doc(currentUserId)
              .get();
          isLiked = likeDoc.exists;
        }
        return PostModel.fromFirestore(doc, isLiked: isLiked);
      }),
    );

    return posts;
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postRef = _firestore.collection('posts').doc(postId);
    final userLikeRef = postRef.collection('likes').doc(user.uid);

    return _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) throw Exception("Post does not exist!");

      final userLikeSnapshot = await transaction.get(userLikeRef);

      if (userLikeSnapshot.exists) {
        transaction.delete(userLikeRef);
        transaction.update(postRef, {'likes': FieldValue.increment(-1)});
      } else {
        transaction.set(userLikeRef, {
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        transaction.update(postRef, {'likes': FieldValue.increment(1)});
      }
    });
  }

  Future<PostModel> createPost({
    required String content,
    required File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    String imageUrl = '';
    if (imageFile != null) {
      final ref = _storage.ref(
        'post_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    final docRef = await _firestore.collection('posts').add({
      'authorId': user.uid,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
      'postImage': imageUrl,
    });

    return PostModel(
      id: docRef.id,
      authorId: user.uid,
      content: content,
      postImage: imageUrl.isNotEmpty ? imageUrl : null,
      likes: 0,
      comments: 0,
      createdAt: DateTime.now(),
      isLiked: false,
    );
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final postRef = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    return _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception('Post does not exist!');
      }

      final newCommentDoc = commentsRef.doc();
      transaction.set(newCommentDoc, {
        'userId': user.uid,
        'content': content.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      transaction.update(postRef, {'comments': FieldValue.increment(1)});
    });
  }
}
