import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_route.dart';
import '../../bloc/matches_bloc.dart';
import '../../bloc/matches_event.dart';
import '../../bloc/matches_state.dart';
import 'match_card.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({super.key});

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefresh() async {
    context.read<MatchesBloc>().add(MatchesSubscriptionRequested());
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const brandRed = Color(0xFFC84E4E);

    return RefreshIndicator(
      color: brandRed,
      onRefresh: _onRefresh,
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          final bool isLoading =
              (state.status == MatchesStatus.initial ||
                  state.status == MatchesStatus.loading) &&
              state.matches.isEmpty;
          final matches = state.matches;

          return CustomScrollView(
            key: const PageStorageKey<String>('matches_scroll_view'),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(Routes.createMatch.path),
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
              ),
              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: brandRed),
                  ),
                )
              else if (matches.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'No matches found.\nBe the first to create a volleyball event! Share your invitation and gather players for a great game!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: brandRed,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final match = matches[index];
                    return MatchCard(
                      match: match,
                      onPressed: () {
                        context.push('/match-details/${match.id}');
                      },
                    );
                  }, childCount: matches.length),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 16.h,
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
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
