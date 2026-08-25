import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<Map<String, dynamic>> _notifications = [
    {
      'type': 'like',
      'profileImage': 'https://picsum.photos/100/100?random=11',
      'action': 'alex92, jonny_dip and 10 others liked your post',
      'time': 'Now',
      'postImage': 'https://picsum.photos/100/100?random=21',
    },
    {
      'type': 'comment',
      'profileImage': 'https://picsum.photos/100/100?random=12',
      'action': 'alicia_20 commented: bleh😒',
      'time': 'Yesterday',
      'postImage': 'https://picsum.photos/100/100?random=22',
    },
    {
      'type': 'reply',
      'profileImage': 'https://picsum.photos/100/100?random=13',
      'action': 'jonny_dip replied to your story: haha, loser',
      'time': 'Yesterday',
      'postImage': 'https://picsum.photos/100/100?random=23',
    },
    {
      'type': 'story_like',
      'profileImage': 'https://picsum.photos/100/100?random=14',
      'action': 'jonny_dip liked your story',
      'time': 'Yesterday',
      'postImage': 'https://picsum.photos/100/100?random=24',
    },
    {
      'type': 'follow',
      'profileImage': 'https://picsum.photos/100/100?random=15',
      'action': 'alicia_20, alexa92 and jonny_dip liked your story',
      'time': '2d',
      'postImage': 'https://picsum.photos/100/100?random=25',
    },
    {
      'type': 'match',
      'profileImage': 'https://picsum.photos/100/100?random=16',
      'action': 'alexa92 added a match - "Hey guys! I’m looking for ..."',
      'time': '1w',
      'postImage': 'https://picsum.photos/100/100?random=26',
    },
    {
      'type': 'like',
      'profileImage': 'https://picsum.photos/100/100?random=17',
      'action': 'alex92, jonny_dip and 10 others liked your post',
      'time': '2w',
      'postImage': 'https://picsum.photos/100/100?random=27',
    },
  ];

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0.5,
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87, size: 24.sp),
            onPressed: () => _handleBack(context),
          ),
        ),
        body: ListView.separated(
          itemCount: _notifications.length,
          separatorBuilder: (_, _) => Divider(
            height: 1.h,
            thickness: 0.5,
            color: Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            return _buildNotificationItem(_notifications[index]);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final String profileImage = notification['profileImage'] ?? '';
    final String postImage = notification['postImage'] ?? '';
    final String action = notification['action'] ?? '';
    final String time = notification['time'] ?? '';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      leading: CircleAvatar(
        radius: 22.r,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: profileImage.startsWith('http')
            ? NetworkImage(profileImage)
            : null,
        onBackgroundImageError: (_, _) {},
        child: !profileImage.startsWith('http')
            ? Icon(Icons.person, color: Colors.grey.shade600, size: 22.sp)
            : null,
      ),
      title: Text(
        action,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ),
      trailing: postImage.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                postImage,
                width: 44.r,
                height: 44.r,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 44.r,
                  height: 44.r,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image_not_supported,
                      size: 18.sp, color: Colors.grey),
                ),
              ),
            )
          : SizedBox(width: 44.r, height: 44.r),
      onTap: () {},
    );
  }
}