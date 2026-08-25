import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import 'post_card.dart';

class HomeFeedView extends StatefulWidget {
  final String currentUserAvatar;

  const HomeFeedView({super.key, required this.currentUserAvatar});

  @override
  State<HomeFeedView> createState() => _HomeFeedViewState();
}

class _HomeFeedViewState extends State<HomeFeedView> {
  late final TextEditingController _postTextController;
  late final FocusNode _focusNode;

  String? _lastError;
  bool _wasPosting = false;

  @override
  void initState() {
    super.initState();
    _postTextController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _postTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitPost() {
    final content = _postTextController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Write something first!')));
      return;
    }

    context.read<HomeBloc>().add(HomePostCreatedRequested(content: content));

    _postTextController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        final errorChanged = previous.errorMessage != current.errorMessage;
        final postingFinished = previous.isPosting && !current.isPosting;
        return errorChanged || postingFinished;
      },
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage != _lastError) {
          _lastError = state.errorMessage;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          return;
        }

        if (_wasPosting && !state.isPosting && state.errorMessage == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Post created!')));
        }

        _wasPosting = state.isPosting;
      },
      builder: (context, state) {
        _wasPosting = state.isPosting;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(HomeRefreshFeedRequested());
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            children: [
              _buildPostInputCard(state),
              SizedBox(height: 12.h),
              _buildFeedContent(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostInputCard(HomeState state) {
    final isPosting = state.isPosting;

    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: NetworkImage(widget.currentUserAvatar),
              onBackgroundImageError: (_, _) {},
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _postTextController,
                focusNode: _focusNode,
                enabled: !isPosting,
                decoration: const InputDecoration(
                  hintText: 'Write something...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isPosting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                elevation: 0,
              ),
              child: isPosting
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(HomeState state) {
    if (state.isLoadingFeed && state.posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No posts yet. Be the first!'),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.posts.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => PostCard(post: state.posts[index]),
    );
  }
}
