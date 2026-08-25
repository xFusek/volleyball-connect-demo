import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../data/models/post_model.dart';
import '../../data/repository/home_repository.dart';
import 'comments_modal.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostAuthorHeader(authorId: post.authorId),
          if (post.content.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Text(
                post.content,
                style: TextStyle(fontSize: 14.sp, height: 1.3),
              ),
            ),
          if (post.postImage != null && post.postImage!.isNotEmpty)
            _PostImage(imageUrl: post.postImage!),
          _PostActionsBar(post: post),
        ],
      ),
    );
  }
}

class _PostAuthorHeader extends StatelessWidget {
  final String authorId;

  const _PostAuthorHeader({required this.authorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final name = userData?['name'] ?? 'Volleyball Player';
        final handle = userData?['handle'] ?? '@player';
        final String? avatar = userData?['image'];
        final bool hasValidAvatar =
            avatar != null && avatar.isNotEmpty && avatar.startsWith('http');

        return Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 4.w, 6.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: hasValidAvatar ? NetworkImage(avatar) : null,
                child: !hasValidAvatar
                    ? Icon(
                        Icons.person,
                        color: Colors.grey.shade600,
                        size: 22.sp,
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    Text(
                      handle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, size: 20.sp),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, _, _) => Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.broken_image, size: 32.sp, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _PostActionsBar extends StatelessWidget {
  final PostModel post;

  const _PostActionsBar({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          _ActionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            iconColor: post.isLiked
                ? const Color(0xFFC84E4E)
                : Colors.grey.shade700,
            count: post.likes,
            onTap: () =>
                context.read<HomeBloc>().add(HomePostLikeToggled(post.id)),
          ),
          SizedBox(width: 8.w),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            iconColor: Colors.grey.shade700,
            count: post.comments,
            onTap: () => CommentsModal.show(
              context,
              postId: post.id,
              repository: HomeRepository(),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              size: 22.sp,
              color: Colors.grey.shade700,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.sp, color: iconColor),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
