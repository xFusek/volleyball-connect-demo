import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ParticipantsListSheet extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final int totalCount;

  const ParticipantsListSheet({
    super.key,
    required this.participants,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.65.sh),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Participants ($totalCount)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          if (participants.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: Text('No participants yet.')),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: participants.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1.h, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final user = participants[index];
                  final String avatar = user['image'] ?? '';
                  final bool hasAvatar =
                      avatar.isNotEmpty && avatar.startsWith('http');

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                    leading: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                      child: !hasAvatar
                          ? Icon(Icons.person, size: 18.sp, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      user['name'] ?? 'Volleyball Player',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
