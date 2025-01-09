import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/pages/watchlists/my_lists.dart';

@GenerateMocks([UserService, WatchlistService])
import '../../../mocks/my_lists_test.mocks.dart';

void main() {
  const String movie1 = '1,,, Movie1,,, poster1.jpg,,, 2023-01-01';
  const String movie2 = '2,,, Movie2,,, poster2.jpg,,, 2023-01-02';
  const String movie3 = '3,,, Movie3,,, poster3.jpg,,, 2023-01-03';

  late MyListsBloc myListsBloc;
  late MockUserService mockUserService;
  late MockWatchlistService mockWatchlistService;

  setUp(() {
    mockUserService = MockUserService();
    mockWatchlistService = MockWatchlistService();
    myListsBloc = MyListsBloc(mockWatchlistService, mockUserService);
  });

  tearDown(() {
    myListsBloc.close();
  });

  group('MyListsBloc Tests', () {
    final testUser = MyUser(
      id: 'test-id',
      username: 'testuser',
      name: 'Test User',
      email: 'test@test.com',
    );

    final testWatchlist = WatchList(
      id: 'test-watchlist-id',
      userID: 'test-id',
      name: 'Test Watchlist',
      isPrivate: false,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      movies: [movie1, movie2, movie3],
      followers: ['follower1'],
      collaborators: ['collab1'],
    );

    test('initial state is MyListsInitial', () {
      expect(myListsBloc.state, isA<MyListsInitial>());
    });

    blocTest<MyListsBloc, MyListsState>(
      'LoadMyLists emits [MyListsLoading, MyListsLoaded] when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockWatchlistService.getOwnWatchLists(testUser.id))
            .thenAnswer((_) async => [testWatchlist]);
        when(mockWatchlistService.getCollabWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getFollowingWatchlists(testUser))
            .thenAnswer((_) async => []);
        return myListsBloc;
      },
      act: (bloc) => bloc.add(LoadMyLists()),
      expect: () => [
        isA<MyListsLoading>(),
        isA<MyListsLoaded>(),
      ],
    );

    blocTest<MyListsBloc, MyListsState>(
      'CreateWatchlist emits [WatchlistCreating, WatchlistCreated] when successful',
      build: () {
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockWatchlistService.createWatchList(testUser, 'Test List', true))
            .thenAnswer((_) async => {});
        when(mockWatchlistService.getOwnWatchLists(testUser.id))
            .thenAnswer((_) async => [testWatchlist]);
        when(mockWatchlistService.getCollabWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getFollowingWatchlists(testUser))
            .thenAnswer((_) async => []);
        return myListsBloc;
      },
      act: (bloc) => bloc.add(CreateWatchlist('Test List', true)),
      expect: () => [
        isA<WatchlistCreating>(),
        isA<WatchlistCreated>(),
        isA<MyListsLoading>(),
        isA<MyListsLoaded>(),
      ],
    );

    blocTest<MyListsBloc, MyListsState>(
      'DeleteWatchlist emits updated state when successful',
      build: () {
        when(mockWatchlistService.deleteWatchList(testWatchlist))
            .thenAnswer((_) async => {});
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockWatchlistService.getOwnWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getCollabWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getFollowingWatchlists(testUser))
            .thenAnswer((_) async => []);
        return myListsBloc;
      },
      act: (bloc) => bloc.add(DeleteWatchlist(testWatchlist)),
      expect: () => [
        isA<MyListsLoading>(),
        isA<MyListsLoaded>(),
      ],
    );

    blocTest<MyListsBloc, MyListsState>(
      'RemoveCollab emits updated state when successful',
      build: () {
        when(mockWatchlistService.removeMyselfAsCollaborator(
          testWatchlist.id,
          testWatchlist.userID,
          testUser.id,
        )).thenAnswer((_) async => {});
        when(mockUserService.getCurrentUser())
            .thenAnswer((_) async => testUser);
        when(mockWatchlistService.getOwnWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getCollabWatchLists(testUser.id))
            .thenAnswer((_) async => []);
        when(mockWatchlistService.getFollowingWatchlists(testUser))
            .thenAnswer((_) async => []);
        return myListsBloc;
      },
      act: (bloc) => bloc.add(RemoveCollab(testWatchlist, testUser.id)),
      expect: () => [
        isA<MyListsLoading>(),
        isA<MyListsLoaded>(),
      ],
    );
  });

  group('MyLists Events Tests', () {
    test('LoadMyLists event properties', () {
      final event = LoadMyLists();
      expect(event, isA<MyListsEvent>());
    });

    test('CreateWatchlist event properties', () {
      const name = 'Test List';
      const isPrivate = true;
      final event = CreateWatchlist(name, isPrivate);
      expect(event.name, equals(name));
      expect(event.isPrivate, equals(isPrivate));
    });

    test('DeleteWatchlist event properties', () {
      final watchlist = WatchList(
        id: 'test-id',
        userID: 'test-user-id',
        name: 'Test List',
        isPrivate: false,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );
      final event = DeleteWatchlist(watchlist);
      expect(event.watchlist, equals(watchlist));
    });

    test('RemoveCollab event properties', () {
      final watchlist = WatchList(
        id: 'test-id',
        userID: 'test-user-id',
        name: 'Test List',
        isPrivate: false,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );
      const userId = 'test-user-id';
      final event = RemoveCollab(watchlist, userId);
      expect(event.watchlist, equals(watchlist));
      expect(event.userId, equals(userId));
    });
  });

  group('MyLists States Tests', () {
    test('MyListsLoading state creation', () {
      final state = MyListsLoading();
      expect(state, isA<MyListsState>());
    });

    test('MyListsLoaded state properties', () {
      final ownWatchlists = [
        WatchList(
          id: 'test-id-1',
          userID: 'test-user-id-1',
          name: 'Test List 1',
          isPrivate: false,
          createdAt: DateTime.now().toString(),
          updatedAt: DateTime.now().toString(),
        )
      ];
      final followedWatchlists = [
        WatchList(
          id: 'test-id-2',
          userID: 'test-user-id-2',
          name: 'Test List 2',
          isPrivate: false,
          createdAt: DateTime.now().toString(),
          updatedAt: DateTime.now().toString(),
        )
      ];
      final state = MyListsLoaded(ownWatchlists, followedWatchlists);
      expect(state.ownWatchlists, equals(ownWatchlists));
      expect(state.followedWatchlists, equals(followedWatchlists));
    });

    test('MyListsError state properties', () {
      const errorMessage = 'Test error';
      final state = MyListsError(errorMessage);
      expect(state.message, equals(errorMessage));
    });

    test('WatchlistCreated state creation', () {
      final state = WatchlistCreated();
      expect(state, isA<MyListsState>());
    });

    test('WatchlistCreating state creation', () {
      final state = WatchlistCreating();
      expect(state, isA<MyListsState>());
    });

    test('WatchlistCreationError state properties', () {
      const errorMessage = 'Test error';
      final state = WatchlistCreationError(errorMessage);
      expect(state.message, equals(errorMessage));
    });
  });
}
