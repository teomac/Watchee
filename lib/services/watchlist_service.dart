import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:logger/logger.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  Future<void> createWatchList(MyUser user, String name, bool isPrivate) async {
    WatchList watchList = WatchList(
      id: user.id + Timestamp.now().toString(),
      userID: user.id,
      name: name,
      isPrivate: isPrivate,
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
    try {
      await _firestore
          .collection('users')
          .doc(watchList.userID)
          .collection('my_watchlists')
          .doc(watchList.id)
          .update(watchList.toMap());
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
    Map<String, List<String>> followedWatchlists = {};

    try {
      QuerySnapshot tempDoc = await _firestore
          .collection('users')
          .doc(user.id)
          .collection('followed_watchlists')
          .get();

      for (DocumentSnapshot doc in tempDoc.docs) {
        followedWatchlists.addAll(doc.data() as Map<String, List<String>>);
      }

      for (String userId in followedWatchlists.keys) {
        for (String watchlistId in followedWatchlists[userId]!) {
          WatchList? watchlist = await getWatchList(userId, watchlistId);
          if (watchlist != null) {
            watchLists.add(watchlist);
          }
        }
      }

      return watchLists;
    } catch (e) {
      logger.e(e);
      return [];
    }
  }
}
