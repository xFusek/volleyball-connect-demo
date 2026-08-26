import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMatchParticipantsPicker extends StatelessWidget {
  final int numberOfPeople;
  final TextEditingController priceController;
  final String currency;
  final ValueChanged<int> onParticipantsChanged;

  const CreateMatchParticipantsPicker({
    super.key,
    required this.numberOfPeople,
    required this.priceController,
    required this.currency,
    required this.onParticipantsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants & Price',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Max: $numberOfPeople',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: numberOfPeople > 2
                              ? () => onParticipantsChanged(numberOfPeople - 1)
                              : null,
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: numberOfPeople < 30
                              ? () => onParticipantsChanged(numberOfPeople + 1)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (optional)',
                  hintText: 'e.g. 15',
                  suffixText: currency,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
