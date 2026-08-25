import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/comment_model.dart';
import '../../data/repository/home_repository.dart';
import 'comment_input_field.dart';
import 'comment_item.dart';

class CommentsModal extends StatelessWidget {
  final String postId;
  final HomeRepository repository;

  const CommentsModal({
    super.key,
    required this.postId,
    required this.repository,
  });

  static void show(
    BuildContext context, {
    required String postId,
    required HomeRepository repository,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsModal(postId: postId, repository: repository),
    );
  }

  Future<void> _addComment(BuildContext context, String text) async {
    try {
      await repository.addComment(postId: postId, content: text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding comment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _buildHeader(context),
            _buildCommentsList(),
            CommentInputField(onSend: (text) => _addComment(context, text)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.h),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20.sp, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return Expanded(
      child: StreamBuilder<List<CommentModel>>(
        stream: repository.getCommentsStream(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFC84E4E)),
            );
          }

          final comments = snapshot.data ?? [];

          if (comments.isEmpty) {
            return Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: comments.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              return CommentItem(
                key: ValueKey(comments[index].id),
                comment: comments[index],
              );
            },
          );
        },
      ),
    );
  }
}
