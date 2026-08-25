abstract class HomeEvent {}

class HomeLoadUserRequested extends HomeEvent {}

class HomeFeedLoadRequested extends HomeEvent {}

class HomePostCreatedRequested extends HomeEvent {
  final String content;
  final String? imageUrl;

  HomePostCreatedRequested({required this.content, this.imageUrl});
}

class HomeRefreshFeedRequested extends HomeEvent {}

class HomePostLikeToggled extends HomeEvent {
  final String postId;

  HomePostLikeToggled(this.postId);
}
