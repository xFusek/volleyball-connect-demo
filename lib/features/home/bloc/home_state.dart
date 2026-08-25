import '../data/models/post_model.dart';

class HomeState {
  final bool isLoadingUser;
  final bool isLoadingFeed;
  final bool isPosting;
  final String? userId;
  final String userAvatarUrl;
  final List<PostModel> posts;
  final String? errorMessage;

  bool get hasAvatar => userAvatarUrl.isNotEmpty && userAvatarUrl.startsWith('http');

  const HomeState({
    this.isLoadingUser = false,
    this.isLoadingFeed = false,
    this.isPosting = false,
    this.userId,
    this.userAvatarUrl = '',
    this.posts = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoadingUser,
    bool? isLoadingFeed,
    bool? isPosting,
    String? userId,
    String? userAvatarUrl,
    List<PostModel>? posts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      isLoadingFeed: isLoadingFeed ?? this.isLoadingFeed,
      isPosting: isPosting ?? this.isPosting,
      userId: userId ?? this.userId,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      posts: posts ?? this.posts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
