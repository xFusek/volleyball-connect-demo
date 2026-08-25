import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/models/comment_model.dart';

final Map<String, Map<String, dynamic>> _userCache = {};

class CommentItem extends StatefulWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  Map<String, dynamic>? _authorData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final uid = widget.comment.userId;
    if (uid.isEmpty) return;

    if (_userCache.containsKey(uid)) {
      if (mounted) {
        setState(() {
          _authorData = _userCache[uid];
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        _userCache[uid] = doc.data()!;
        if (mounted) {
          setState(() {
            _authorData = doc.data();
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _authorData == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Colors.grey.shade200,
              child: SizedBox(
                width: 12.r,
                height: 12.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFFC84E4E),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.comment.content,
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final name = _authorData?['name'] ?? 'User';
    final String? avatar = _authorData?['image'];
    final bool hasAvatar =
        avatar != null && avatar.isNotEmpty && avatar.startsWith('http');
    final formattedTime = timeago.format(
      widget.comment.createdAt,
      locale: 'en',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
          child: !hasAvatar
              ? Icon(Icons.person, size: 18.sp, color: Colors.grey.shade600)
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                widget.comment.content,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.black87,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                formattedTime,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
