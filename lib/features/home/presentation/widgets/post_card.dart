import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(post.authorId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const ListTile(
                  title: Text('Loading...'),
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final name = userData?['name'] ?? 'Unknown User';
              final handle = userData?['handle'] ?? '@unknown';
              final avatar = userData?['image'] ?? 'https://firebasestorage.googleapis.com/v0/b/social-appv.appspot.com/o/user_avatar%2Ftemplate.jpg?alt=media&token=2a543c75-eef6-41e6-a1b6-23db552f4099';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(avatar),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  handle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              );
            },
          ),

          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.content,
                style: const TextStyle(fontSize: 14, height: 1.3),
              ),
            ),

          if (post.postImage != null && post.postImage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  post.postImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _buildReactionButton(Icons.favorite_border, 'Like', () {}),
                _buildReactionButton(Icons.chat_bubble_outline, 'Comment', () {}),
                _buildReactionButton(Icons.shortcut_outlined, 'Share', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: const Color(0xFFC84E4E)),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}