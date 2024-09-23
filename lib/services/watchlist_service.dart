import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/services/user_service.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();
  final UserService _userService = UserService();

  Future<void> createWatchList(MyUser user, String name, bool isPrivate) async {
    WatchList watchList = WatchList(
      id: user.id + DateTime.now().toString(),
      userID: user.id,
      name: name,
      isPrivate: isPrivate,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );

    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .collection('my_watchlists')
          .doc(watchList.id)
          .set(watchList.toMap());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> updateWatchList(WatchList watchList) async {
    WatchList updatedWatchList =
        watchList.copyWith(updatedAt: DateTime.now().toString());
    try {
      await _firestore
          .collection('users')
          .doc(watchList.userID)
          .collection('my_watchlists')
          .doc(watchList.id)
          .update(updatedWatchList.toMap());
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> deleteWatchList(WatchList watchList) async {
    try {
      await _firestore
          .collection('users')
          .doc(watchList.userID)
          .collection('my_watchlists')
          .doc(watchList.id)
          .delete();
    } catch (e) {
      logger.e(e);
    }
  }

  Future<List<WatchList>> getOwnWatchLists(String userId) async {
    try {
      QuerySnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_watchlists')
          .get();
      return doc.docs.map((doc) => WatchList.fromFirestore(doc)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<List<WatchList>> getPublicWatchLists(String userId) async {
    try {
      QuerySnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_watchlists')
          .where('isPrivate', isEqualTo: false)
          .get();
      return doc.docs.map((doc) => WatchList.fromFirestore(doc)).toList();
    } catch (e) {
      logger.e(e);
      return [];
    }
  }

  Future<WatchList?> getWatchList(String userId, String watchListId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_watchlists')
          .doc(watchListId)
          .get();
      return doc.exists ? WatchList.fromFirestore(doc) : null;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  Future<List<WatchList>> getFollowingWatchlists(MyUser user) async {
    List<WatchList> watchLists = [];

    for (var entry in user.followedWatchlists.entries) {
      var key = entry.key;
      var value = entry.value;
      for (var watchlistId in value) {
        WatchList? watchlist = await getWatchList(key, watchlistId);
        if (watchlist != null) {
          watchLists.add(watchlist);
        }
      }
    }
    return watchLists;
  }

  Future<void> followWatchlist(
      String userId, String watchlistId, String watchlistOwner) async {
    MyUser? user = await _userService.getUser(userId);

    try {
      if (user!.followedWatchlists.containsKey(watchlistOwner)) {
        user.followedWatchlists[watchlistOwner]!.add(watchlistId);
      } else {
        user.followedWatchlists[watchlistOwner] = [watchlistId];
      }
      _userService.updateUser(user);

      //add follower to the watchlist
      await _firestore
          .collection('users')
          .doc(watchlistOwner)
          .collection('my_watchlists')
          .doc(watchlistId)
          .update({
        'followers': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> unfollowWatchlist(
      String userId, String watchlistId, String watchlistOwner) async {
    MyUser? user = await _userService.getUser(userId);

    try {
      if (user!.followedWatchlists.containsKey(watchlistOwner)) {
        user.followedWatchlists[watchlistOwner]!.remove(watchlistId);
        _userService.updateUser(user);
      }
      //remove follower from the watchlist
      await _firestore
          .collection('users')
          .doc(watchlistOwner)
          .collection('my_watchlists')
          .doc(watchlistId)
          .update({
        'followers': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> addMovieToWatchlist(
      String userId, String watchlistId, int movieId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_watchlists')
          .doc(watchlistId)
          .get();
      //add movie id to the watchlist
      WatchList watchlist = WatchList.fromFirestore(doc);
      watchlist.movies.add(movieId);
      watchlist = watchlist.copyWith(updatedAt: DateTime.now().toString());
      await updateWatchList(watchlist);
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> removeMovieFromWatchlist(
      String userId, String watchlistId, int movieId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('my_watchlists')
          .doc(watchlistId)
          .get();
      //add movie id to the watchlist
      WatchList watchlist = WatchList.fromFirestore(doc);
      watchlist.movies.remove(movieId);
      watchlist = watchlist.copyWith(updatedAt: DateTime.now().toString());
      await updateWatchList(watchlist);
    } catch (e) {
      logger.e(e);
    }
  }
}
