import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/features/home/bloc/home_bloc.dart';
import 'package:social_app/features/home/bloc/home_event.dart';
import 'package:social_app/features/home/bloc/home_state.dart';
import 'package:social_app/features/home/data/models/post_model.dart';
import 'package:social_app/features/home/data/repository/home_repository.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockHomeRepository;

  final dummyPost = PostModel(
    id: 'post_1',
    authorId: 'user_1',
    content: 'Trening siatkówki o 18:00',
    createdAt: DateTime.now(),
    likes: 2,
    comments: 0,
    isLiked: false,
  );

  setUp(() {
    mockHomeRepository = MockHomeRepository();
  });

  group('HomeBloc Unit Tests', () {
    test('initial state has default empty values', () {
      final bloc = HomeBloc(mockHomeRepository);
      expect(bloc.state.posts, isEmpty);
      expect(bloc.state.isLoadingFeed, isFalse);
      expect(bloc.state.isPosting, isFalse);
      expect(bloc.state.errorMessage, isNull);
    });

    blocTest<HomeBloc, HomeState>(
      'emits [isLoadingFeed: true, isLoadingFeed: false] with posts on success',
      build: () {
        when(() => mockHomeRepository.fetchPosts())
            .thenAnswer((_) async => [dummyPost]);
        return HomeBloc(mockHomeRepository);
      },
      act: (bloc) => bloc.add(HomeFeedLoadRequested()),
      expect: () => [
        isA<HomeState>().having((s) => s.isLoadingFeed, 'isLoadingFeed', true),
        isA<HomeState>()
            .having((s) => s.isLoadingFeed, 'isLoadingFeed', false)
            .having((s) => s.posts.length, 'posts length', 1),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits error state when feed loading fails',
      build: () {
        when(() => mockHomeRepository.fetchPosts())
            .thenThrow(Exception('Network error'));
        return HomeBloc(mockHomeRepository);
      },
      act: (bloc) => bloc.add(HomeFeedLoadRequested()),
      expect: () => [
        isA<HomeState>().having((s) => s.isLoadingFeed, 'isLoadingFeed', true),
        isA<HomeState>()
            .having((s) => s.isLoadingFeed, 'isLoadingFeed', false)
            .having((s) => s.errorMessage, 'errorMessage', contains('Network error')),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'optimistically toggles like and increments count',
      build: () {
        when(() => mockHomeRepository.toggleLike('post_1'))
            .thenAnswer((_) async {});
        return HomeBloc(mockHomeRepository);
      },
      seed: () => HomeState(posts: [dummyPost]),
      act: (bloc) => bloc.add(HomePostLikeToggled('post_1')),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.posts.first.isLiked, 'isLiked', true)
            .having((s) => s.posts.first.likes, 'likes count', 3),
      ],
      verify: (_) {
        verify(() => mockHomeRepository.toggleLike('post_1')).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'triggers feed reload (rollback) when toggleLike fails',
      build: () {
        when(() => mockHomeRepository.toggleLike('post_1'))
            .thenThrow(Exception('Failed to toggle like'));
        when(() => mockHomeRepository.fetchPosts())
            .thenAnswer((_) async => [dummyPost]);
        return HomeBloc(mockHomeRepository);
      },
      seed: () => HomeState(posts: [dummyPost]),
      act: (bloc) => bloc.add(HomePostLikeToggled('post_1')),
      expect: () => [
        isA<HomeState>().having((s) => s.posts.first.isLiked, 'isLiked', true),
        isA<HomeState>().having((s) => s.isLoadingFeed, 'isLoadingFeed', true),
        isA<HomeState>()
            .having((s) => s.isLoadingFeed, 'isLoadingFeed', false)
            .having((s) => s.posts.first.isLiked, 'isLiked restored', false),
      ],
      verify: (_) {
        verify(() => mockHomeRepository.toggleLike('post_1')).called(1);
        verify(() => mockHomeRepository.fetchPosts()).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits error when creating a post fails',
      build: () {
        when(() => mockHomeRepository.createPost(
              content: 'Failed post',
              imageFile: null,
            )).thenThrow(Exception('Firestore error'));
        return HomeBloc(mockHomeRepository);
      },
      act: (bloc) => bloc.add(HomePostCreatedRequested(content: 'Failed post')),
      expect: () => [
        isA<HomeState>().having((s) => s.isPosting, 'isPosting', true),
        isA<HomeState>()
            .having((s) => s.isPosting, 'isPosting', false)
            .having((s) => s.errorMessage, 'errorMessage', contains('Firestore error')),
      ],
    );
  });
}