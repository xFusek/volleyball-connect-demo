import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeLoadUserRequested>(_onLoadUser);
    on<HomeFeedLoadRequested>(_onLoadFeed);
    on<HomePostCreatedRequested>(_onCreatePost);
    on<HomeRefreshFeedRequested>(_onRefreshFeed);
    on<HomePostLikeToggled>(_onToggleLike);
  }

  Future<void> _onLoadUser(
    HomeLoadUserRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.userId != null && state.posts.isNotEmpty) return;
    emit(state.copyWith(isLoadingUser: true, clearError: true));

    try {
      final user = await _repository.loadCurrentUser();

      emit(
        state.copyWith(
          isLoadingUser: false,
          userId: user.id,
          userAvatarUrl: user.avatarUrl,
        ),
      );

      add(HomeFeedLoadRequested());
    } catch (e) {
      emit(state.copyWith(isLoadingUser: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadFeed(
    HomeFeedLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingFeed: true, clearError: true));

    try {
      final posts = await _repository.fetchPosts();
      emit(state.copyWith(isLoadingFeed: false, posts: posts));
    } catch (e) {
      emit(state.copyWith(isLoadingFeed: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleLike(
    HomePostLikeToggled event,
    Emitter<HomeState> emit,
  ) async {
    final updatedPosts = state.posts.map((post) {
      if (post.id == event.postId) {
        final willBeLiked = !post.isLiked;
        return post.copyWith(
          isLiked: willBeLiked,
          likes: willBeLiked
              ? post.likes + 1
              : (post.likes > 0 ? post.likes - 1 : 0),
        );
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));

    try {
      await _repository.toggleLike(event.postId);
    } catch (e) {
      add(HomeFeedLoadRequested());
    }
  }

  Future<void> _onCreatePost(
    HomePostCreatedRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isPosting: true, clearError: true));

    try {
      await _repository.createPost(content: event.content, imageFile: null);
      final posts = await _repository.fetchPosts();
      emit(state.copyWith(isPosting: false, posts: posts));
    } catch (e) {
      emit(state.copyWith(isPosting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshFeed(
    HomeRefreshFeedRequested event,
    Emitter<HomeState> emit,
  ) async {
    add(HomeFeedLoadRequested());
  }
}
