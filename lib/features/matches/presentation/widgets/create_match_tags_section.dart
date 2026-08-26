import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMatchTagsSection extends StatelessWidget {
  final String selectedTeam;
  final String selectedLocationType;
  final String selectedExperience;
  final ValueChanged<String> onTeamChanged;
  final ValueChanged<String> onLocationTypeChanged;
  final ValueChanged<String> onExperienceChanged;

  const CreateMatchTagsSection({
    super.key,
    required this.selectedTeam,
    required this.selectedLocationType,
    required this.selectedExperience,
    required this.onTeamChanged,
    required this.onLocationTypeChanged,
    required this.onExperienceChanged,
  });

  Widget _buildChip(
    String label,
    String currentVal,
    ValueChanged<String> onSelect,
  ) {
    final bool isSelected = currentVal == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFC84E4E),
      backgroundColor: Colors.grey.shade100,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isSelected ? const Color(0xFFC84E4E) : Colors.grey.shade300,
        ),
      ),
      onSelected: (_) => onSelect(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags & Preferences',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            _buildChip('mixed team', selectedTeam, onTeamChanged),
            _buildChip('female team', selectedTeam, onTeamChanged),
            _buildChip('male team', selectedTeam, onTeamChanged),
            _buildChip('indoor', selectedLocationType, onLocationTypeChanged),
            _buildChip('outdoor', selectedLocationType, onLocationTypeChanged),
            _buildChip('experienced', selectedExperience, onExperienceChanged),
            _buildChip('all levels', selectedExperience, onExperienceChanged),
            _buildChip(
              'no experience',
              selectedExperience,
              onExperienceChanged,
            ),
          ],
        ),
      ],
    );
  }
}
