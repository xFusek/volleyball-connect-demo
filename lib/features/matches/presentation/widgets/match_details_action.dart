import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchDetailsActions extends StatelessWidget {
  final bool isOwner;
  final bool isParticipant;
  final bool isToggleLoading;
  final bool isDeleteLoading;
  final bool isParticipantsLoading;
  final int participantsCount;
  final VoidCallback onCheckParticipants;
  final VoidCallback onToggleParticipation;
  final VoidCallback onDeleteMatch;

  const MatchDetailsActions({
    super.key,
    required this.isOwner,
    required this.isParticipant,
    required this.isToggleLoading,
    required this.isDeleteLoading,
    required this.isParticipantsLoading,
    required this.participantsCount,
    required this.onCheckParticipants,
    required this.onToggleParticipation,
    required this.onDeleteMatch,
  });

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC84E4E);
    const joinGreen = Color(0xFF2DD81A);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton(
            onPressed: isParticipantsLoading ? null : onCheckParticipants,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade800,
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: isParticipantsLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Check Participants ($participantsCount)',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        if (isOwner)
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: isDeleteLoading ? null : onDeleteMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: isDeleteLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Delete Match',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: isToggleLoading ? null : onToggleParticipation,
              style: ElevatedButton.styleFrom(
                backgroundColor: isParticipant ? brandRed : joinGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: isToggleLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isParticipant ? 'Leave Match' : 'Join Match',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
