import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onCheckPressed;

  const MatchCard({
    super.key,
    required this.match,
    this.onCheckPressed,
  });

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC84E4E);
    final displayedParticipants = match.participants.isNotEmpty
        ? match.participants.length - 1
        : 0;

    return Card(
      elevation: 0.5,
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 90.w,
                        height: 120.h,
                        color: Colors.grey.shade100,
                        child: match.customImageUrl != null && match.customImageUrl!.isNotEmpty
                            ? Image.network(match.customImageUrl!, fit: BoxFit.cover)
                            : Image.asset(
                                'assets/icons/homepage/matches/gleboka31.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.sports_volleyball,
                                  size: 36.sp,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 48.w),
                            child: Text(
                              match.header,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey.shade600, size: 16.sp),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  match.location,
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          if (match.tags.isNotEmpty)
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 4.h,
                              children: match.tags.map((tag) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1AAFD8),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              )).toList(),
                            ),
                          SizedBox(height: 8.h),
                          Text(
                            match.description,
                            style: TextStyle(fontSize: 12.sp, color: Colors.black87, height: 1.25),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: onCheckPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Check', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12.h,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '$displayedParticipants/${match.maxParticipants}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: brandRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}