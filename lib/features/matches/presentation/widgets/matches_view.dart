import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_route.dart';
import '../../data/models/match_model.dart';
import '../../data/repository/matches_repository.dart';
import 'match_card.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({super.key});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with AutomaticKeepAliveClientMixin {
  final MatchesRepository _matchesRepository = MatchesRepository();
  late final Stream<List<MatchModel>> _matchesStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _matchesStream = _matchesRepository.getMatchesStream();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const brandRed = Color(0xFFC84E4E);

    return RefreshIndicator(
      color: brandRed,
      onRefresh: _onRefresh,
      child: StreamBuilder<List<MatchModel>>(
        stream: _matchesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: brandRed));
          }

          final matches = snapshot.data ?? [];

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Tworzenie meczu
                  },
                  icon: Icon(Icons.add, size: 20.sp),
                  label: Text(
                    'Add match',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRed,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 44.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (matches.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 48.h,
                  ),
                  child: Text(
                    'No matches found.\nBe the first to create a volleyball event! Share your invitation and gather players for a great game!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: brandRed,
                      height: 1.4,
                    ),
                  ),
                )
              else ...[
                ...matches.map(
                  (match) => MatchCard(
                    match: match,
                    onCheckPressed: () {
                      context.push(
                        Routes.matchDetails.path,
                        extra: match,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: Text(
                    'Share your invitation and gather players for a great game!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}