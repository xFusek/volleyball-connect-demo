import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../widgets/home_feed_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<HomeBloc>().add(HomeLoadUserRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandRed = Color(0xFFC84E4E);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final userAvatarUrl = state.userAvatarUrl;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  pinned: true,
                  floating: false,
                  primary: false,
                  title: Text(
                    'VolleyballConnect',
                    style: TextStyle(
                      color: brandRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                  actions: [
                    _buildBadgeIconButton(
                      icon: Icons.notifications_outlined,
                      badgeCount: '99+',
                      onTap: () {},
                    ),
                    _buildBadgeIconButton(
                      icon: Icons.send_outlined,
                      badgeCount: '99+',
                      onTap: () {},
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    height: 96.h,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      children: [
                        _buildStoryAddButton(userAvatarUrl),
                        _buildStoryItem(
                          'https://picsum.photos/200/300?random=1',
                          borderColor: Colors.orange,
                        ),
                        _buildStoryItem(
                          'https://picsum.photos/200/300?random=2',
                          borderColor: Colors.cyan,
                        ),
                        _buildStoryItem(
                          'https://picsum.photos/200/300?random=3',
                          borderColor: Colors.orange,
                        ),
                        _buildStoryItem(
                          'https://picsum.photos/200/300?random=4',
                          borderColor: Colors.amber,
                        ),
                        _buildStoryItem(
                          'https://picsum.photos/200/300?random=5',
                          borderColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: brandRed,
                      indicatorWeight: 3.h,
                      labelColor: brandRed,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(icon: Icon(Icons.home, size: 28.sp)),
                        Tab(icon: Icon(Icons.people_outline, size: 28.sp)),
                        Tab(icon: Icon(Icons.sports_volleyball, size: 28.sp)),
                        Tab(icon: Icon(Icons.menu, size: 28.sp)),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  HomeFeedView(currentUserAvatar: userAvatarUrl),
                  const Center(child: Text('Friends Tab')),
                  const Center(child: Text('Matches Tab')),
                  const Center(child: Text('Settings Tab')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeIconButton({
    required IconData icon,
    required String badgeCount,
    required VoidCallback onTap,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.black87, size: 24.sp),
          onPressed: onTap,
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFC84E4E),
              borderRadius: BorderRadius.circular(10.r),
            ),
            constraints: BoxConstraints(minWidth: 16.w, minHeight: 14.h),
            child: Text(
              badgeCount,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoryAddButton(String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (_, _) {},
          ),
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 26.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String imageUrl, {required Color borderColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        padding: EdgeInsets.all(2.5.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2.w),
        ),
        child: CircleAvatar(
          radius: 29.r,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (_, _) {},
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
