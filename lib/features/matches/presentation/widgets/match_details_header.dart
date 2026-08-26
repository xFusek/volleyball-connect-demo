import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/match_model.dart';

class MatchDetailsHeader extends StatelessWidget {
  final MatchModel match;

  const MatchDetailsHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final String? networkUrl = match.customImageUrl;
    final String? assetPath = kLocationImages[match.location];
    final bool hasImage =
        (networkUrl != null && networkUrl.isNotEmpty) || assetPath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            width: double.infinity,
            height: 140.h,
            color: Colors.black,
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImageWidget(
                        networkUrl: networkUrl,
                        assetPath: assetPath,
                        fit: BoxFit.cover,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                      _buildImageWidget(
                        networkUrl: networkUrl,
                        assetPath: assetPath,
                        fit: BoxFit.contain,
                      ),
                    ],
                  )
                : _buildFallback(Icons.sports_volleyball),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          match.header,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.grey.shade600, size: 16.sp),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                match.location,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageWidget({
    required String? networkUrl,
    required String? assetPath,
    required BoxFit fit,
  }) {
    if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _buildFallback(Icons.broken_image),
      );
    }
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: fit,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _buildFallback(Icons.broken_image),
      );
    }
    return _buildFallback(Icons.sports_volleyball);
  }

  Widget _buildFallback(IconData icon) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(icon, size: 36.sp, color: Colors.grey),
    );
  }
}
