// Mocks generated by Mockito 5.4.4 from annotations
// in dima_project/test/widget/pages/movies/film_details_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:io' as _i11;

import 'package:dima_project/models/movie.dart' as _i2;
import 'package:dima_project/models/movie_review.dart' as _i12;
import 'package:dima_project/models/person.dart' as _i3;
import 'package:dima_project/models/tiny_movie.dart' as _i15;
import 'package:dima_project/models/user.dart' as _i10;
import 'package:dima_project/models/watchlist.dart' as _i14;
import 'package:dima_project/services/tmdb_api_service.dart' as _i5;
import 'package:dima_project/services/user_service.dart' as _i9;
import 'package:dima_project/services/watchlist_service.dart' as _i13;
import 'package:http/http.dart' as _i7;
import 'package:logger/logger.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeMovie_0 extends _i1.SmartFake implements _i2.Movie {
  _FakeMovie_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePerson_1 extends _i1.SmartFake implements _i3.Person {
  _FakePerson_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLogger_2 extends _i1.SmartFake implements _i4.Logger {
  _FakeLogger_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TmdbApiService].
///
/// See the documentation for Mockito's code generation for more information.
class MockTmdbApiService extends _i1.Mock implements _i5.TmdbApiService {
  MockTmdbApiService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<List<_i2.Movie>> fetchTrendingMovies([_i7.Client? client]) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchTrendingMovies,
          [client],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchNowPlayingMovies() => (super.noSuchMethod(
        Invocation.method(
          #fetchNowPlayingMovies,
          [],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchTopRatedMovies() => (super.noSuchMethod(
        Invocation.method(
          #fetchTopRatedMovies,
          [],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchUpcomingMovies() => (super.noSuchMethod(
        Invocation.method(
          #fetchUpcomingMovies,
          [],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<_i2.Movie> retrieveFilmInfo(int? movieId) => (super.noSuchMethod(
        Invocation.method(
          #retrieveFilmInfo,
          [movieId],
        ),
        returnValue: _i6.Future<_i2.Movie>.value(_FakeMovie_0(
          this,
          Invocation.method(
            #retrieveFilmInfo,
            [movieId],
          ),
        )),
      ) as _i6.Future<_i2.Movie>);

  @override
  _i6.Future<List<Map<String, dynamic>>> retrieveCast(int? movieId) =>
      (super.noSuchMethod(
        Invocation.method(
          #retrieveCast,
          [movieId],
        ),
        returnValue: _i6.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i6.Future<List<Map<String, dynamic>>>);

  @override
  _i6.Future<String> retrieveTrailer(int? movieId) => (super.noSuchMethod(
        Invocation.method(
          #retrieveTrailer,
          [movieId],
        ),
        returnValue: _i6.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #retrieveTrailer,
            [movieId],
          ),
        )),
      ) as _i6.Future<String>);

  @override
  _i6.Future<List<_i2.Movie>> searchMovie(String? query) => (super.noSuchMethod(
        Invocation.method(
          #searchMovie,
          [query],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchMoviesByReleaseDate(String? releaseDate) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchMoviesByReleaseDate,
          [releaseDate],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<Map<String, List<Map<String, dynamic>>>> fetchAllProviders(
          int? movieId) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchAllProviders,
          [movieId],
        ),
        returnValue: _i6.Future<Map<String, List<Map<String, dynamic>>>>.value(
            <String, List<Map<String, dynamic>>>{}),
      ) as _i6.Future<Map<String, List<Map<String, dynamic>>>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchMoviesByGenres(List<int>? genreIds) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchMoviesByGenres,
          [genreIds],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i2.Movie>> fetchRecommendedMovies(int? movieId) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchRecommendedMovies,
          [movieId],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);

  @override
  _i6.Future<List<_i3.Person>> searchPeople(String? query) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchPeople,
          [query],
        ),
        returnValue: _i6.Future<List<_i3.Person>>.value(<_i3.Person>[]),
      ) as _i6.Future<List<_i3.Person>>);

  @override
  _i6.Future<_i3.Person> fetchPersonDetails(int? personId) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchPersonDetails,
          [personId],
        ),
        returnValue: _i6.Future<_i3.Person>.value(_FakePerson_1(
          this,
          Invocation.method(
            #fetchPersonDetails,
            [personId],
          ),
        )),
      ) as _i6.Future<_i3.Person>);

  @override
  _i6.Future<List<_i2.Movie>> fetchPersonMovies(int? personId) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchPersonMovies,
          [personId],
        ),
        returnValue: _i6.Future<List<_i2.Movie>>.value(<_i2.Movie>[]),
      ) as _i6.Future<List<_i2.Movie>>);
}

/// A class which mocks [UserService].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserService extends _i1.Mock implements _i9.UserService {
  MockUserService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_2(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i4.Logger);

  @override
  _i6.Future<void> createUser(_i10.MyUser? user) => (super.noSuchMethod(
        Invocation.method(
          #createUser,
          [user],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i10.MyUser?> getUser(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #getUser,
          [userId],
        ),
        returnValue: _i6.Future<_i10.MyUser?>.value(),
      ) as _i6.Future<_i10.MyUser?>);

  @override
  _i6.Future<void> updateUser(_i10.MyUser? user) => (super.noSuchMethod(
        Invocation.method(
          #updateUser,
          [user],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> deleteUser(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #deleteUser,
          [userId],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> followUser(
    String? currentUserId,
    String? userToFollowId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #followUser,
          [
            currentUserId,
            userToFollowId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> unfollowUser(
    String? currentUserId,
    String? userToUnfollowId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #unfollowUser,
          [
            currentUserId,
            userToUnfollowId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeFollower(
    String? currentUserId,
    String? followerToRemoveId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeFollower,
          [
            currentUserId,
            followerToRemoveId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<_i10.MyUser>> getFollowers(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowers,
          [userId],
        ),
        returnValue: _i6.Future<List<_i10.MyUser>>.value(<_i10.MyUser>[]),
      ) as _i6.Future<List<_i10.MyUser>>);

  @override
  _i6.Future<List<_i10.MyUser>> getFollowing(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowing,
          [userId],
        ),
        returnValue: _i6.Future<List<_i10.MyUser>>.value(<_i10.MyUser>[]),
      ) as _i6.Future<List<_i10.MyUser>>);

  @override
  _i6.Future<bool> isFollowing(
    String? currentUserId,
    String? otherUserId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #isFollowing,
          [
            currentUserId,
            otherUserId,
          ],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<List<_i10.MyUser>> searchUsers(String? query) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchUsers,
          [query],
        ),
        returnValue: _i6.Future<List<_i10.MyUser>>.value(<_i10.MyUser>[]),
      ) as _i6.Future<List<_i10.MyUser>>);

  @override
  _i6.Future<void> updateUserWithNameLowerCase(
    String? userId,
    String? name,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUserWithNameLowerCase,
          [
            userId,
            name,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<bool> isUsernameAvailable(String? username) => (super.noSuchMethod(
        Invocation.method(
          #isUsernameAvailable,
          [username],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<_i10.MyUser?> getCurrentUser() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [],
        ),
        returnValue: _i6.Future<_i10.MyUser?>.value(),
      ) as _i6.Future<_i10.MyUser?>);

  @override
  _i6.Future<void> addCustomList(
    String? userId,
    String? listName,
    List<String>? movies,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addCustomList,
          [
            userId,
            listName,
            movies,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeCustomList(
    String? userId,
    String? listName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeCustomList,
          [
            userId,
            listName,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String> getUniqueUsername(String? baseUsername) =>
      (super.noSuchMethod(
        Invocation.method(
          #getUniqueUsername,
          [baseUsername],
        ),
        returnValue: _i6.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #getUniqueUsername,
            [baseUsername],
          ),
        )),
      ) as _i6.Future<String>);

  @override
  _i6.Future<String?> uploadImage(_i11.File? image) => (super.noSuchMethod(
        Invocation.method(
          #uploadImage,
          [image],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<void> addMovieReview(
    String? userId,
    int? movieId,
    int? rating,
    String? text,
    String? title,
    String? username,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addMovieReview,
          [
            userId,
            movieId,
            rating,
            text,
            title,
            username,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<_i12.MovieReview>> getReviewsForMovie(String? movieId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getReviewsForMovie,
          [movieId],
        ),
        returnValue:
            _i6.Future<List<_i12.MovieReview>>.value(<_i12.MovieReview>[]),
      ) as _i6.Future<List<_i12.MovieReview>>);

  @override
  _i6.Future<List<_i12.MovieReview>> getReviewsByUser(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getReviewsByUser,
          [userId],
        ),
        returnValue:
            _i6.Future<List<_i12.MovieReview>>.value(<_i12.MovieReview>[]),
      ) as _i6.Future<List<_i12.MovieReview>>);

  @override
  _i6.Future<List<_i12.MovieReview>> getFriendsReviews(
    String? currentUserId,
    int? movieId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFriendsReviews,
          [
            currentUserId,
            movieId,
          ],
        ),
        returnValue:
            _i6.Future<List<_i12.MovieReview>>.value(<_i12.MovieReview>[]),
      ) as _i6.Future<List<_i12.MovieReview>>);

  @override
  _i6.Future<void> addToLikedMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addToLikedMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeFromLikedMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeFromLikedMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<String>> getLikedMovieIds(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLikedMovieIds,
          [userId],
        ),
        returnValue: _i6.Future<List<String>>.value(<String>[]),
      ) as _i6.Future<List<String>>);

  @override
  _i6.Future<void> addToSeenMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addToSeenMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeFromSeenMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeFromSeenMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<String>> getSeenMovieIds(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getSeenMovieIds,
          [userId],
        ),
        returnValue: _i6.Future<List<String>>.value(<String>[]),
      ) as _i6.Future<List<String>>);

  @override
  _i6.Future<bool> checkLikedMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #checkLikedMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<bool> checkSeenMovies(
    String? userId,
    String? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #checkSeenMovies,
          [
            userId,
            movie,
          ],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<void> deleteReviews(
    String? userId,
    List<_i12.MovieReview>? reviews,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteReviews,
          [
            userId,
            reviews,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<Map<String, dynamic>>> getNotifications(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getNotifications,
          [userId],
        ),
        returnValue: _i6.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i6.Future<List<Map<String, dynamic>>>);

  @override
  _i6.Future<void> clearNotifications(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #clearNotifications,
          [userId],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeNotification(
    String? userId,
    String? notificationId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeNotification,
          [
            userId,
            notificationId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updateUsernameInReviews(
    String? userId,
    String? newUsername,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateUsernameInReviews,
          [
            userId,
            newUsername,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}

/// A class which mocks [WatchlistService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWatchlistService extends _i1.Mock implements _i13.WatchlistService {
  MockWatchlistService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_2(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i4.Logger);

  @override
  _i6.Future<void> createWatchList(
    _i10.MyUser? user,
    String? name,
    bool? isPrivate,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createWatchList,
          [
            user,
            name,
            isPrivate,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> updateWatchList(_i14.WatchList? watchList) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateWatchList,
          [watchList],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> deleteWatchList(_i14.WatchList? watchList) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteWatchList,
          [watchList],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<List<_i14.WatchList>> getOwnWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getOwnWatchLists,
          [userId],
        ),
        returnValue: _i6.Future<List<_i14.WatchList>>.value(<_i14.WatchList>[]),
      ) as _i6.Future<List<_i14.WatchList>>);

  @override
  _i6.Future<List<_i14.WatchList>> getCollabWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCollabWatchLists,
          [userId],
        ),
        returnValue: _i6.Future<List<_i14.WatchList>>.value(<_i14.WatchList>[]),
      ) as _i6.Future<List<_i14.WatchList>>);

  @override
  _i6.Future<List<_i14.WatchList>> getPublicWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPublicWatchLists,
          [userId],
        ),
        returnValue: _i6.Future<List<_i14.WatchList>>.value(<_i14.WatchList>[]),
      ) as _i6.Future<List<_i14.WatchList>>);

  @override
  _i6.Future<_i14.WatchList?> getWatchList(
    String? userId,
    String? watchListId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getWatchList,
          [
            userId,
            watchListId,
          ],
        ),
        returnValue: _i6.Future<_i14.WatchList?>.value(),
      ) as _i6.Future<_i14.WatchList?>);

  @override
  _i6.Future<List<_i14.WatchList>> getFollowingWatchlists(_i10.MyUser? user) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowingWatchlists,
          [user],
        ),
        returnValue: _i6.Future<List<_i14.WatchList>>.value(<_i14.WatchList>[]),
      ) as _i6.Future<List<_i14.WatchList>>);

  @override
  _i6.Future<void> followWatchlist(
    String? userId,
    String? watchlistId,
    String? watchlistOwner,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #followWatchlist,
          [
            userId,
            watchlistId,
            watchlistOwner,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> unfollowWatchlist(
    String? userId,
    String? watchlistId,
    String? watchlistOwner,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #unfollowWatchlist,
          [
            userId,
            watchlistId,
            watchlistOwner,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> addMovieToWatchlist(
    String? userId,
    String? watchlistId,
    _i15.Tinymovie? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addMovieToWatchlist,
          [
            userId,
            watchlistId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeMovieFromWatchlist(
    String? userId,
    String? watchlistId,
    _i15.Tinymovie? movie,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeMovieFromWatchlist,
          [
            userId,
            watchlistId,
            movie,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<bool> inviteCollaborator(
    String? watchlistId,
    String? watchlistOwner,
    String? userId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #inviteCollaborator,
          [
            watchlistId,
            watchlistOwner,
            userId,
          ],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<void> acceptInvite(
    String? watchlistId,
    String? watchlistOwner,
    String? userId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #acceptInvite,
          [
            watchlistId,
            watchlistOwner,
            userId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> declineInvite(
    String? watchlistId,
    String? watchlistOwner,
    String? userId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #declineInvite,
          [
            watchlistId,
            watchlistOwner,
            userId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> removeMyselfAsCollaborator(
    String? watchlistId,
    String? watchlistOwner,
    String? userId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeMyselfAsCollaborator,
          [
            watchlistId,
            watchlistOwner,
            userId,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
}
