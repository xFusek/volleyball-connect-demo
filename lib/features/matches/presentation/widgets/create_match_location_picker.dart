import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/match_model.dart';

class CreateMatchLocationPicker extends StatelessWidget {
  final String selectedLocation;
  final ValueChanged<String> onLocationChanged;

  const CreateMatchLocationPicker({
    super.key,
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: selectedLocation,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: kLocationImages.keys
              .map(
                (loc) => DropdownMenuItem(
                  value: loc,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: Image.asset(
                          kLocationImages[loc]!,
                          width: 36.w,
                          height: 36.h,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 36.w,
                            height: 36.h,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.sports_volleyball,
                              size: 20.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          loc,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onLocationChanged(val);
          },
        ),
      ],
    );
  }
}
