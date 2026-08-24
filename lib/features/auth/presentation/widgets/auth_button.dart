import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AuthButtonType { primary, secondary, google }

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AuthButtonType type;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AuthButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == AuthButtonType.primary;
    final isGoogle = type == AuthButtonType.google;

    if (isGoogle) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : SvgPicture.asset('assets/icons/google_icon.svg', height: 20.h),
        label: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          side: const BorderSide(color: Colors.black, width: 1.5),
        ),
      );
    }

    // Przycisk Primary / Secondary
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : Colors.black,
        backgroundColor: isPrimary ? const Color(0xFFC84E4E) : Colors.white,
        elevation: 0,
        side: isPrimary
            ? null
            : const BorderSide(color: Colors.black, width: 1.5),
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isPrimary ? Colors.white : Colors.black,
              ),
            )
          : Text(
              text,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
    );
  }
}