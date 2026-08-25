import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/match_model.dart';
import '../../data/repository/matches_repository.dart';

enum MatchActionLoading { none, toggleJoin, deleteMatch, loadParticipants }

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchesRepository _repository = MatchesRepository();
  static final Map<String, Map<String, dynamic>> _usersCache = {};

  late List<String> _participants;
  late bool _isParticipant;
  late bool _isOwner;
  late String _currentUserId;

  MatchActionLoading _loadingState = MatchActionLoading.none;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _participants = List<String>.from(widget.match.participants);
    _isParticipant = _participants.contains(_currentUserId);
    _isOwner = widget.match.ownerId == _currentUserId;
  }

  Future<void> _handleToggleParticipation() async {
    setState(() => _loadingState = MatchActionLoading.toggleJoin);

    final willJoin = !_isParticipant;
    setState(() {
      _isParticipant = willJoin;
      if (willJoin) {
        _participants.add(_currentUserId);
      } else {
        _participants.remove(_currentUserId);
      }
    });

    try {
      await _repository.toggleParticipation(
        matchId: widget.match.id,
        userId: _currentUserId,
        isCurrentlyJoined: !willJoin,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isParticipant = !willJoin;
          if (willJoin) {
            _participants.remove(_currentUserId);
          } else {
            _participants.add(_currentUserId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update participation: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingState = MatchActionLoading.none);
    }
  }

  Future<void> _handleDeleteMatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text(
          'Are you sure you want to delete this match event?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loadingState = MatchActionLoading.deleteMatch);
    try {
      await _repository.deleteMatch(widget.match.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _loadingState = MatchActionLoading.none);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting match: $e')));
      }
    }
  }

  Future<void> _showParticipantsSheet() async {
    if (_participants.isEmpty) {
      _openSheet([]);
      return;
    }

    final List<Map<String, dynamic>> loadedUsers = [];
    final List<String> idsToFetch = [];

    for (final id in _participants) {
      if (_usersCache.containsKey(id)) {
        loadedUsers.add(_usersCache[id]!);
      } else {
        idsToFetch.add(id);
      }
    }

    if (idsToFetch.isNotEmpty) {
      setState(() => _loadingState = MatchActionLoading.loadParticipants);
      try {
        final snapshots = await Future.wait(
          idsToFetch.map((id) =>
              FirebaseFirestore.instance.collection('users').doc(id).get()),
        );

        for (final doc in snapshots) {
          final data = doc.data() ?? {};
          final userData = {
            'id': doc.id,
            'name': data['name'] ?? 'Volleyball Player',
            'image': data['image'] ?? '',
          };
          _usersCache[doc.id] = userData;
          loadedUsers.add(userData);
        }
      } finally {
        if (mounted) setState(() => _loadingState = MatchActionLoading.none);
      }
    }

    if (mounted) {
      _openSheet(loadedUsers);
    }
  }

  void _openSheet(List<Map<String, dynamic>> participants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _ParticipantsListSheet(
        participants: participants,
        totalCount: _participants.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC84E4E);
    const joinGreen = Color(0xFF2DD81A);

    final bool isParticipantsLoading =
        _loadingState == MatchActionLoading.loadParticipants;
    final bool isDeleteLoading =
        _loadingState == MatchActionLoading.deleteMatch;
    final bool isToggleLoading =
        _loadingState == MatchActionLoading.toggleJoin;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Match Details',
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
              widget.match.header,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey.shade600,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    widget.match.location,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_outlined, size: 20.sp, color: brandRed),
                  SizedBox(width: 8.w),
                  Text(
                    'Participants: ${_participants.length}/${widget.match.maxParticipants}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            if (widget.match.tags.isNotEmpty)
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: widget.match.tags
                    .map(
                      (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1AAFD8),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                widget.match.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: OutlinedButton(
                onPressed: isParticipantsLoading ? null : _showParticipantsSheet,
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
                            'Check Participants (${_participants.length})',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            if (_isOwner)
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: isDeleteLoading ? null : _handleDeleteMatch,
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
                  onPressed: isToggleLoading ? null : _handleToggleParticipation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isParticipant ? brandRed : joinGreen,
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
                          _isParticipant ? 'Leave Match' : 'Join Match',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsListSheet extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final int totalCount;

  const _ParticipantsListSheet({
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
                      backgroundImage:
                          hasAvatar ? NetworkImage(avatar) : null,
                      child: !hasAvatar
                          ? Icon(Icons.person,
                              size: 18.sp, color: Colors.grey)
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