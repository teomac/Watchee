// Mocks generated by Mockito 5.4.4 from annotations
// in dima_project/test/widget/pages/watchlists/my_lists_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:io' as _i12;
import 'dart:typed_data' as _i14;

import 'package:cloud_firestore/cloud_firestore.dart' as _i4;
import 'package:dima_project/models/movie_review.dart' as _i13;
import 'package:dima_project/models/tiny_movie.dart' as _i9;
import 'package:dima_project/models/user.dart' as _i7;
import 'package:dima_project/models/watchlist.dart' as _i8;
import 'package:dima_project/services/custom_auth.dart' as _i15;
import 'package:dima_project/services/notifications_service.dart' as _i17;
import 'package:dima_project/services/user_service.dart' as _i10;
import 'package:dima_project/services/watchlist_service.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i16;
import 'package:firebase_core/firebase_core.dart' as _i3;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i11;

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

class _FakeLogger_0 extends _i1.SmartFake implements _i2.Logger {
  _FakeLogger_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseApp_1 extends _i1.SmartFake implements _i3.FirebaseApp {
  _FakeFirebaseApp_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSettings_2 extends _i1.SmartFake implements _i4.Settings {
  _FakeSettings_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCollectionReference_3<T extends Object?> extends _i1.SmartFake
    implements _i4.CollectionReference<T> {
  _FakeCollectionReference_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWriteBatch_4 extends _i1.SmartFake implements _i4.WriteBatch {
  _FakeWriteBatch_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLoadBundleTask_5 extends _i1.SmartFake
    implements _i4.LoadBundleTask {
  _FakeLoadBundleTask_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuerySnapshot_6<T1 extends Object?> extends _i1.SmartFake
    implements _i4.QuerySnapshot<T1> {
  _FakeQuerySnapshot_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuery_7<T extends Object?> extends _i1.SmartFake
    implements _i4.Query<T> {
  _FakeQuery_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDocumentReference_8<T extends Object?> extends _i1.SmartFake
    implements _i4.DocumentReference<T> {
  _FakeDocumentReference_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_9<T1> extends _i1.SmartFake implements _i5.Future<T1> {
  _FakeFuture_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [WatchlistService].
///
/// See the documentation for Mockito's code generation for more information.
class MockWatchlistService extends _i1.Mock implements _i6.WatchlistService {
  MockWatchlistService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i2.Logger);

  @override
  _i5.Future<void> createWatchList(
    _i7.MyUser? user,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> updateWatchList(_i8.WatchList? watchList) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateWatchList,
          [watchList],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> deleteWatchList(_i8.WatchList? watchList) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteWatchList,
          [watchList],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i8.WatchList>> getOwnWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getOwnWatchLists,
          [userId],
        ),
        returnValue: _i5.Future<List<_i8.WatchList>>.value(<_i8.WatchList>[]),
      ) as _i5.Future<List<_i8.WatchList>>);

  @override
  _i5.Future<List<_i8.WatchList>> getCollabWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCollabWatchLists,
          [userId],
        ),
        returnValue: _i5.Future<List<_i8.WatchList>>.value(<_i8.WatchList>[]),
      ) as _i5.Future<List<_i8.WatchList>>);

  @override
  _i5.Future<List<_i8.WatchList>> getPublicWatchLists(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPublicWatchLists,
          [userId],
        ),
        returnValue: _i5.Future<List<_i8.WatchList>>.value(<_i8.WatchList>[]),
      ) as _i5.Future<List<_i8.WatchList>>);

  @override
  _i5.Future<_i8.WatchList?> getWatchList(
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
        returnValue: _i5.Future<_i8.WatchList?>.value(),
      ) as _i5.Future<_i8.WatchList?>);

  @override
  _i5.Future<List<_i8.WatchList>> getFollowingWatchlists(_i7.MyUser? user) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowingWatchlists,
          [user],
        ),
        returnValue: _i5.Future<List<_i8.WatchList>>.value(<_i8.WatchList>[]),
      ) as _i5.Future<List<_i8.WatchList>>);

  @override
  _i5.Future<void> followWatchlist(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> unfollowWatchlist(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> addMovieToWatchlist(
    String? userId,
    String? watchlistId,
    _i9.Tinymovie? movie,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeMovieFromWatchlist(
    String? userId,
    String? watchlistId,
    _i9.Tinymovie? movie,
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> inviteCollaborator(
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
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> acceptInvite(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> declineInvite(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeMyselfAsCollaborator(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [UserService].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserService extends _i1.Mock implements _i10.UserService {
  MockUserService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i2.Logger);

  @override
  _i5.Future<void> createUser(_i7.MyUser? user) => (super.noSuchMethod(
        Invocation.method(
          #createUser,
          [user],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<_i7.MyUser?> getUser(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #getUser,
          [userId],
        ),
        returnValue: _i5.Future<_i7.MyUser?>.value(),
      ) as _i5.Future<_i7.MyUser?>);

  @override
  _i5.Future<void> updateUser(_i7.MyUser? user) => (super.noSuchMethod(
        Invocation.method(
          #updateUser,
          [user],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> deleteUser(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #deleteUser,
          [userId],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> followUser(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> unfollowUser(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeFollower(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i7.MyUser>> getFollowers(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowers,
          [userId],
        ),
        returnValue: _i5.Future<List<_i7.MyUser>>.value(<_i7.MyUser>[]),
      ) as _i5.Future<List<_i7.MyUser>>);

  @override
  _i5.Future<List<_i7.MyUser>> getFollowing(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFollowing,
          [userId],
        ),
        returnValue: _i5.Future<List<_i7.MyUser>>.value(<_i7.MyUser>[]),
      ) as _i5.Future<List<_i7.MyUser>>);

  @override
  _i5.Future<bool> isFollowing(
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
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<List<_i7.MyUser>> searchUsers(String? query) =>
      (super.noSuchMethod(
        Invocation.method(
          #searchUsers,
          [query],
        ),
        returnValue: _i5.Future<List<_i7.MyUser>>.value(<_i7.MyUser>[]),
      ) as _i5.Future<List<_i7.MyUser>>);

  @override
  _i5.Future<void> updateUserWithNameLowerCase(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> isUsernameAvailable(String? username) => (super.noSuchMethod(
        Invocation.method(
          #isUsernameAvailable,
          [username],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<_i7.MyUser?> getCurrentUser() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentUser,
          [],
        ),
        returnValue: _i5.Future<_i7.MyUser?>.value(),
      ) as _i5.Future<_i7.MyUser?>);

  @override
  _i5.Future<void> addCustomList(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeCustomList(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String> getUniqueUsername(String? baseUsername) =>
      (super.noSuchMethod(
        Invocation.method(
          #getUniqueUsername,
          [baseUsername],
        ),
        returnValue: _i5.Future<String>.value(_i11.dummyValue<String>(
          this,
          Invocation.method(
            #getUniqueUsername,
            [baseUsername],
          ),
        )),
      ) as _i5.Future<String>);

  @override
  _i5.Future<String?> uploadImage(_i12.File? image) => (super.noSuchMethod(
        Invocation.method(
          #uploadImage,
          [image],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<void> addMovieReview(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<_i13.MovieReview>> getReviewsForMovie(String? movieId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getReviewsForMovie,
          [movieId],
        ),
        returnValue:
            _i5.Future<List<_i13.MovieReview>>.value(<_i13.MovieReview>[]),
      ) as _i5.Future<List<_i13.MovieReview>>);

  @override
  _i5.Future<List<_i13.MovieReview>> getReviewsByUser(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getReviewsByUser,
          [userId],
        ),
        returnValue:
            _i5.Future<List<_i13.MovieReview>>.value(<_i13.MovieReview>[]),
      ) as _i5.Future<List<_i13.MovieReview>>);

  @override
  _i5.Future<List<_i13.MovieReview>> getFriendsReviews(
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
            _i5.Future<List<_i13.MovieReview>>.value(<_i13.MovieReview>[]),
      ) as _i5.Future<List<_i13.MovieReview>>);

  @override
  _i5.Future<void> addToLikedMovies(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeFromLikedMovies(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<String>> getLikedMovieIds(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLikedMovieIds,
          [userId],
        ),
        returnValue: _i5.Future<List<String>>.value(<String>[]),
      ) as _i5.Future<List<String>>);

  @override
  _i5.Future<void> addToSeenMovies(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeFromSeenMovies(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<String>> getSeenMovieIds(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getSeenMovieIds,
          [userId],
        ),
        returnValue: _i5.Future<List<String>>.value(<String>[]),
      ) as _i5.Future<List<String>>);

  @override
  _i5.Future<bool> checkLikedMovies(
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
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<bool> checkSeenMovies(
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
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> deleteReviews(
    String? userId,
    List<_i13.MovieReview>? reviews,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteReviews,
          [
            userId,
            reviews,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<Map<String, dynamic>>> getNotifications(String? userId) =>
      (super.noSuchMethod(
        Invocation.method(
          #getNotifications,
          [userId],
        ),
        returnValue: _i5.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i5.Future<List<Map<String, dynamic>>>);

  @override
  _i5.Future<void> clearNotifications(String? userId) => (super.noSuchMethod(
        Invocation.method(
          #clearNotifications,
          [userId],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> removeNotification(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> updateUsernameInReviews(
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
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [FirebaseFirestore].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFirestore extends _i1.Mock implements _i4.FirebaseFirestore {
  MockFirebaseFirestore() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_1(
          this,
          Invocation.getter(#app),
        ),
      ) as _i3.FirebaseApp);

  @override
  set app(_i3.FirebaseApp? _app) => super.noSuchMethod(
        Invocation.setter(
          #app,
          _app,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseURL => (super.noSuchMethod(
        Invocation.getter(#databaseURL),
        returnValue: _i11.dummyValue<String>(
          this,
          Invocation.getter(#databaseURL),
        ),
      ) as String);

  @override
  set databaseURL(String? _databaseURL) => super.noSuchMethod(
        Invocation.setter(
          #databaseURL,
          _databaseURL,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseId => (super.noSuchMethod(
        Invocation.getter(#databaseId),
        returnValue: _i11.dummyValue<String>(
          this,
          Invocation.getter(#databaseId),
        ),
      ) as String);

  @override
  set databaseId(String? _databaseId) => super.noSuchMethod(
        Invocation.setter(
          #databaseId,
          _databaseId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set settings(_i4.Settings? settings) => super.noSuchMethod(
        Invocation.setter(
          #settings,
          settings,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Settings get settings => (super.noSuchMethod(
        Invocation.getter(#settings),
        returnValue: _FakeSettings_2(
          this,
          Invocation.getter(#settings),
        ),
      ) as _i4.Settings);

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  _i4.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collection,
          [collectionPath],
        ),
        returnValue: _FakeCollectionReference_3<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collection,
            [collectionPath],
          ),
        ),
      ) as _i4.CollectionReference<Map<String, dynamic>>);

  @override
  _i4.WriteBatch batch() => (super.noSuchMethod(
        Invocation.method(
          #batch,
          [],
        ),
        returnValue: _FakeWriteBatch_4(
          this,
          Invocation.method(
            #batch,
            [],
          ),
        ),
      ) as _i4.WriteBatch);

  @override
  _i5.Future<void> clearPersistence() => (super.noSuchMethod(
        Invocation.method(
          #clearPersistence,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> enablePersistence(
          [_i4.PersistenceSettings? persistenceSettings]) =>
      (super.noSuchMethod(
        Invocation.method(
          #enablePersistence,
          [persistenceSettings],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.LoadBundleTask loadBundle(_i14.Uint8List? bundle) => (super.noSuchMethod(
        Invocation.method(
          #loadBundle,
          [bundle],
        ),
        returnValue: _FakeLoadBundleTask_5(
          this,
          Invocation.method(
            #loadBundle,
            [bundle],
          ),
        ),
      ) as _i4.LoadBundleTask);

  @override
  void useFirestoreEmulator(
    String? host,
    int? port, {
    bool? sslEnabled = false,
    bool? automaticHostMapping = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #useFirestoreEmulator,
          [
            host,
            port,
          ],
          {
            #sslEnabled: sslEnabled,
            #automaticHostMapping: automaticHostMapping,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i4.QuerySnapshot<T>> namedQueryWithConverterGet<T>(
    String? name, {
    _i4.GetOptions? options = const _i4.GetOptions(),
    required _i4.FromFirestore<T>? fromFirestore,
    required _i4.ToFirestore<T>? toFirestore,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryWithConverterGet,
          [name],
          {
            #options: options,
            #fromFirestore: fromFirestore,
            #toFirestore: toFirestore,
          },
        ),
        returnValue:
            _i5.Future<_i4.QuerySnapshot<T>>.value(_FakeQuerySnapshot_6<T>(
          this,
          Invocation.method(
            #namedQueryWithConverterGet,
            [name],
            {
              #options: options,
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        )),
      ) as _i5.Future<_i4.QuerySnapshot<T>>);

  @override
  _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
    String? name, {
    _i4.GetOptions? options = const _i4.GetOptions(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryGet,
          [name],
          {#options: options},
        ),
        returnValue: _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>.value(
            _FakeQuerySnapshot_6<Map<String, dynamic>>(
          this,
          Invocation.method(
            #namedQueryGet,
            [name],
            {#options: options},
          ),
        )),
      ) as _i5.Future<_i4.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i4.Query<Map<String, dynamic>> collectionGroup(String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collectionGroup,
          [collectionPath],
        ),
        returnValue: _FakeQuery_7<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collectionGroup,
            [collectionPath],
          ),
        ),
      ) as _i4.Query<Map<String, dynamic>>);

  @override
  _i5.Future<void> disableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #disableNetwork,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i4.DocumentReference<Map<String, dynamic>> doc(String? documentPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #doc,
          [documentPath],
        ),
        returnValue: _FakeDocumentReference_8<Map<String, dynamic>>(
          this,
          Invocation.method(
            #doc,
            [documentPath],
          ),
        ),
      ) as _i4.DocumentReference<Map<String, dynamic>>);

  @override
  _i5.Future<void> enableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #enableNetwork,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Stream<void> snapshotsInSync() => (super.noSuchMethod(
        Invocation.method(
          #snapshotsInSync,
          [],
        ),
        returnValue: _i5.Stream<void>.empty(),
      ) as _i5.Stream<void>);

  @override
  _i5.Future<T> runTransaction<T>(
    _i4.TransactionHandler<T>? transactionHandler, {
    Duration? timeout = const Duration(seconds: 30),
    int? maxAttempts = 5,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runTransaction,
          [transactionHandler],
          {
            #timeout: timeout,
            #maxAttempts: maxAttempts,
          },
        ),
        returnValue: _i11.ifNotNull(
              _i11.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runTransaction,
                  [transactionHandler],
                  {
                    #timeout: timeout,
                    #maxAttempts: maxAttempts,
                  },
                ),
              ),
              (T v) => _i5.Future<T>.value(v),
            ) ??
            _FakeFuture_9<T>(
              this,
              Invocation.method(
                #runTransaction,
                [transactionHandler],
                {
                  #timeout: timeout,
                  #maxAttempts: maxAttempts,
                },
              ),
            ),
      ) as _i5.Future<T>);

  @override
  _i5.Future<void> terminate() => (super.noSuchMethod(
        Invocation.method(
          #terminate,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> waitForPendingWrites() => (super.noSuchMethod(
        Invocation.method(
          #waitForPendingWrites,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfiguration({
    required List<_i4.Index>? indexes,
    List<_i4.FieldOverrides>? fieldOverrides,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfiguration,
          [],
          {
            #indexes: indexes,
            #fieldOverrides: fieldOverrides,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setIndexConfigurationFromJSON(String? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfigurationFromJSON,
          [json],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [CustomAuth].
///
/// See the documentation for Mockito's code generation for more information.
class MockCustomAuth extends _i1.Mock implements _i15.CustomAuth {
  MockCustomAuth() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get logger => (super.noSuchMethod(
        Invocation.getter(#logger),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#logger),
        ),
      ) as _i2.Logger);

  @override
  _i5.Stream<_i16.User?> get authStateChanges => (super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: _i5.Stream<_i16.User?>.empty(),
      ) as _i5.Stream<_i16.User?>);

  @override
  _i5.Future<void> signInWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #signInWithEmailAndPassword,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> createUserWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createUserWithEmailAndPassword,
          [],
          {
            #email: email,
            #password: password,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
}

/// A class which mocks [NotificationsService].
///
/// See the documentation for Mockito's code generation for more information.
class MockNotificationsService extends _i1.Mock
    implements _i17.NotificationsService {
  MockNotificationsService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get unreadCount => (super.noSuchMethod(
        Invocation.getter(#unreadCount),
        returnValue: 0,
      ) as int);

  @override
  void incrementUnreadCount() => super.noSuchMethod(
        Invocation.method(
          #incrementUnreadCount,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void resetUnreadCount() => super.noSuchMethod(
        Invocation.method(
          #resetUnreadCount,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
