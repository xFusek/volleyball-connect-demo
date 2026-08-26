import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/match_model.dart';
import '../../data/repository/matches_repository.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';
import '../widgets/match_details_action.dart';
import '../widgets/match_details_header.dart';
import '../widgets/match_details_info.dart';
import '../widgets/participants_list_sheet.dart';

enum MatchActionLoading { none, toggleJoin, deleteMatch, loadParticipants }

class MatchDetailsScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  static final Map<String, Map<String, dynamic>> _usersCache = {};
  final MatchesRepository _repository = MatchesRepository();

  late String _currentUserId;
  MatchActionLoading _loadingState = MatchActionLoading.none;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _handleToggleParticipation(bool isParticipant) {
    setState(() => _loadingState = MatchActionLoading.toggleJoin);
    context.read<MatchesBloc>().add(
      MatchesToggleParticipationRequested(
        matchId: widget.matchId,
        isCurrentlyJoined: isParticipant,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _loadingState = MatchActionLoading.none);
    });
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
    if (mounted) {
      context.read<MatchesBloc>().add(MatchesDeleteRequested(widget.matchId));
      Navigator.of(context).pop();
    }
  }

  Future<void> _showParticipantsSheet(List<String> participantIds) async {
    if (participantIds.isEmpty) {
      _openSheet([], 0);
      return;
    }

    final List<Map<String, dynamic>> loadedUsers = [];
    final List<String> idsToFetch = [];

    for (final id in participantIds) {
      if (_usersCache.containsKey(id)) {
        loadedUsers.add(_usersCache[id]!);
      } else {
        idsToFetch.add(id);
      }
    }

    if (idsToFetch.isNotEmpty) {
      setState(() => _loadingState = MatchActionLoading.loadParticipants);
      try {
        final fetched = await _repository.fetchParticipantsData(idsToFetch);
        for (final user in fetched) {
          _usersCache[user['id']] = user;
          loadedUsers.add(user);
        }
      } finally {
        if (mounted) setState(() => _loadingState = MatchActionLoading.none);
      }
    }

    if (mounted) _openSheet(loadedUsers, participantIds.length);
  }

  void _openSheet(List<Map<String, dynamic>> participants, int count) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) =>
          ParticipantsListSheet(participants: participants, totalCount: count),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        final currentMatch = state.matches.firstWhere(
          (m) => m.id == widget.matchId,
          orElse: () => MatchModel(
            id: widget.matchId,
            ownerId: '',
            header: 'Match Details',
            location: '',
            description: '',
            tags: const [],
            participants: const [],
            maxParticipants: 12,
          ),
        );

        final isOwner = currentMatch.ownerId == _currentUserId;
        final participants = currentMatch.participants;
        final isParticipant = participants.contains(_currentUserId);

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
                MatchDetailsHeader(match: currentMatch),
                SizedBox(height: 12.h),
                MatchDetailsInfo(
                  match: currentMatch,
                  participantsCount: participants.length,
                ),
                SizedBox(height: 24.h),
                MatchDetailsActions(
                  isOwner: isOwner,
                  isParticipant: isParticipant,
                  isToggleLoading:
                      _loadingState == MatchActionLoading.toggleJoin,
                  isDeleteLoading:
                      _loadingState == MatchActionLoading.deleteMatch,
                  isParticipantsLoading:
                      _loadingState == MatchActionLoading.loadParticipants,
                  participantsCount: participants.length,
                  onCheckParticipants: () =>
                      _showParticipantsSheet(participants),
                  onToggleParticipation: () =>
                      _handleToggleParticipation(isParticipant),
                  onDeleteMatch: _handleDeleteMatch,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
