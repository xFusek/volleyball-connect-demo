import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
      avatarUrl: data['image'] ?? 'https://picsum.photos/200/300?random=5',
    );
  }

  Future<List<PostModel>> fetchPosts() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
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
      'postImage': imageUrl.isNotEmpty ? imageUrl : '',
    });

    return PostModel(
      id: docRef.id,
      authorId: user.uid,
      content: content,
      postImage: imageUrl.isNotEmpty ? imageUrl : null,
      likes: 0,
      comments: 0,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel> fetchUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data() ?? {};

    return UserModel(
      id: userId,
      name: data['name'] ?? 'Unknown',
      handle: data['handle'] ?? '@unknown',
      avatarUrl:
          data['image'] ??
          'https://firebasestorage.googleapis.com/v0/b/social-appv.appspot.com/o/user_avatar%2Ftemplate.jpg?alt=media&token=2a543c75-eef6-41e6-a1b6-23db552f4099',
    );
  }
}
