import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';
import '../widgets/create_match_tags_section.dart';
import '../widgets/create_match_location_picker.dart';
import '../widgets/create_match_participants_picker.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedTeam = 'mixed team';
  String _selectedLocationType = 'indoor';
  String _selectedExperience = 'experienced';
  int _numberOfPeople = 12;
  final String _selectedCurrency = 'PLN';
  String _selectedLocationAddress = 'ulica Ignacego Rzeckiego 10, Lublin';

  @override
  void dispose() {
    _headerController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleCreateMatch() {
    if (_headerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a header')));
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    final String combinedCurrency = _priceController.text.trim().isEmpty
        ? 'Free'
        : '${_priceController.text.trim()} $_selectedCurrency';

    context.read<MatchesBloc>().add(
      MatchesCreateRequested(
        header: _headerController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _selectedLocationAddress,
        tags: [_selectedTeam, _selectedLocationType, _selectedExperience],
        maxParticipants: _numberOfPeople,
        currency: combinedCurrency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC84E4E);

    return BlocConsumer<MatchesBloc, MatchesState>(
      listenWhen: (prev, curr) =>
          prev.isActionInProgress != curr.isActionInProgress ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (!state.isActionInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match invitation created!')),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isLoading = state.isActionInProgress;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: Text(
              'Create Match',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0.5,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Details',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _headerController,
                  decoration: InputDecoration(
                    labelText: 'Header / Title',
                    hintText: 'e.g. Friendly Volleyball 6v6',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add details about skill level, rules, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                CreateMatchTagsSection(
                  selectedTeam: _selectedTeam,
                  selectedLocationType: _selectedLocationType,
                  selectedExperience: _selectedExperience,
                  onTeamChanged: (val) => setState(() => _selectedTeam = val),
                  onLocationTypeChanged: (val) =>
                      setState(() => _selectedLocationType = val),
                  onExperienceChanged: (val) =>
                      setState(() => _selectedExperience = val),
                ),
                SizedBox(height: 16.h),
                CreateMatchLocationPicker(
                  selectedLocation: _selectedLocationAddress,
                  onLocationChanged: (val) =>
                      setState(() => _selectedLocationAddress = val),
                ),
                SizedBox(height: 16.h),
                CreateMatchParticipantsPicker(
                  numberOfPeople: _numberOfPeople,
                  priceController: _priceController,
                  currency: _selectedCurrency,
                  onParticipantsChanged: (val) =>
                      setState(() => _numberOfPeople = val),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleCreateMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Match Invitation',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
