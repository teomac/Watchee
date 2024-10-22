import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/pages/follow/follow_page.dart';

@GenerateMocks([UserService])
import 'follow_page_test.mocks.dart';

void main() {
  late FollowBloc followBloc;
  late MockUserService mockUserService;

  setUp(() {
    mockUserService = MockUserService();
    followBloc = FollowBloc(mockUserService);
  });

  tearDown(() {
    followBloc.close();
  });

  group('FollowBloc Tests', () {
    final testUser = MyUser(
      id: 'test-id',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
    );

    test('initial state is FollowInitial', () {
      expect(followBloc.state, isA<FollowInitial>());
    });

    blocTest<FollowBloc, FollowState>(
      'LoadFollowData emits [FollowLoading, FollowDataLoaded] when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockUserService.getFollowing(testUser.id))
            .thenAnswer((_) async => [testUser]);
        when(mockUserService.getFollowers(testUser.id))
            .thenAnswer((_) async => [testUser]);
        return followBloc;
      },
      act: (bloc) => bloc.add(LoadFollowData()),
      expect: () => [
        isA<FollowLoading>(),
        isA<FollowDataLoaded>(),
      ],
    );

    blocTest<FollowBloc, FollowState>(
      'SearchUsers emits [SearchResultsLoaded] with results when query is valid',
      build: () {
        when(mockUserService.searchUsers('test'))
            .thenAnswer((_) async => [testUser]);
        return followBloc;
      },
      act: (bloc) => bloc.add(SearchUsers('test')),
      expect: () => [
        isA<SearchResultsLoaded>(),
      ],
    );

    blocTest<FollowBloc, FollowState>(
      'SearchUsers emits empty results when query is less than 3 characters',
      build: () => followBloc,
      act: (bloc) => bloc.add(SearchUsers('te')),
      expect: () => [
        isA<SearchResultsLoaded>(),
      ],
      verify: (bloc) {
        verifyNever(mockUserService.searchUsers(any));
      },
    );

    blocTest<FollowBloc, FollowState>(
      'UnfollowUser emits updated state when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockUserService.unfollowUser(any, any))
            .thenAnswer((_) async => {});
        return followBloc;
      },
      seed: () => FollowDataLoaded([testUser], [testUser]),
      act: (bloc) => bloc.add(UnfollowUser(testUser)),
      expect: () => [
        isA<FollowDataLoaded>(),
      ],
    );

    blocTest<FollowBloc, FollowState>(
      'RemoveFollower emits updated state when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockUserService.removeFollower(any, any))
            .thenAnswer((_) async => {});
        when(mockUserService.getFollowing(testUser.id))
            .thenAnswer((_) async => [testUser]);
        when(mockUserService.getFollowers(testUser.id))
            .thenAnswer((_) async => [testUser]);
        return followBloc;
      },
      seed: () => FollowDataLoaded([testUser], [testUser]),
      act: (bloc) => bloc.add(RemoveFollower(testUser)),
      expect: () => [
        isA<FollowLoading>(),
        isA<FollowDataLoaded>(),
      ],
    );

    blocTest<FollowBloc, FollowState>(
      'RemoveFollower emits updated state when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockUserService.removeFollower(any, any))
            .thenAnswer((_) async => {});
        when(mockUserService.getFollowing(testUser.id))
            .thenAnswer((_) async => [testUser]);
        when(mockUserService.getFollowers(testUser.id))
            .thenAnswer((_) async => [testUser]);
        return followBloc;
      },
      seed: () => FollowDataLoaded([testUser], [testUser]),
      act: (bloc) => bloc.add(RemoveFollower(testUser)),
      expect: () => [
        isA<FollowLoading>(),
        isA<FollowDataLoaded>(),
      ],
    );
  });

  group('Follow Events Tests', () {
    test('LoadFollowData event properties', () {
      final event = LoadFollowData();
      expect(event, isA<FollowEvent>());
    });

    test('SearchUsers event properties', () {
      const query = 'test';
      final event = SearchUsers(query);
      expect(event.query, equals(query));
    });

    test('UnfollowUser event properties', () {
      final user = MyUser(
        id: 'test-id',
        username: 'testuser',
        name: 'Test User',
        email: 'test@test.com',
      );
      final event = UnfollowUser(user);
      expect(event.user, equals(user));
    });

    test('RemoveFollower event properties', () {
      final user = MyUser(
        id: 'test-id',
        username: 'testuser',
        name: 'Test User',
        email: 'test@test.com',
      );
      final event = RemoveFollower(user);
      expect(event.user, equals(user));
    });
  });

  group('Follow States Tests', () {
    test('FollowLoading state creation', () {
      final state = FollowLoading();
      expect(state, isA<FollowState>());
    });

    test('FollowDataLoaded state properties', () {
      final following = [
        MyUser(
          id: 'test-id-1',
          username: 'testuser1',
          name: 'Test User 1',
          email: 'test1@test.com',
        )
      ];
      final followers = [
        MyUser(
          id: 'test-id-2',
          username: 'testuser2',
          name: 'Test User 2',
          email: 'test2@test.com',
        )
      ];
      final state = FollowDataLoaded(following, followers);
      expect(state.following, equals(following));
      expect(state.followers, equals(followers));
    });

    test('FollowError state properties', () {
      const errorMessage = 'Test error';
      final state = FollowError(errorMessage);
      expect(state.message, equals(errorMessage));
    });

    test('SearchResultsLoaded state properties', () {
      final users = [
        MyUser(
          id: 'test-id',
          username: 'testuser',
          name: 'Test User',
          email: 'test@test.com',
        )
      ];
      final state = SearchResultsLoaded(users);
      expect(state.users, equals(users));
    });
  });
}
