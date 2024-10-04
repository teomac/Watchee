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
    DocumentReference docRef = await _firestore
        .collection('users')
        .doc(user.id)
        .collection('my_watchlists')
        .add({});

    WatchList watchList = WatchList(
      id: docRef.id,
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
      //check if it has collaborators
      if (watchList.collaborators.isNotEmpty) {
        //remove watchlist value from collabWatchlist map in each collaborator
        for (var collaborator in watchList.collaborators) {
          await _firestore.collection('users').doc(collaborator).update({
            'collabWatchlists.${watchList.userID}':
                FieldValue.arrayRemove([watchList.id])
          });
        }
      }

      //remove watchlist for each follower
      for (var follower in watchList.followers) {
        await _firestore.collection('users').doc(follower).update({
          'followedWatchlists.${watchList.userID}':
              FieldValue.arrayRemove([watchList.id])
        });
      }

      //delete watchlist
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

  Future<List<WatchList>> getCollabWatchLists(String userId) async {
    List<WatchList> watchLists = [];
    try {
      //get user document
      MyUser? user = await _userService.getUser(userId);
      for (var key in user!.collabWatchlists.keys) {
        for (var watchlistId in user.collabWatchlists[key]!) {
          QuerySnapshot querySnapshot = await _firestore
              .collection('users')
              .doc(key)
              .collection('my_watchlists')
              .where(FieldPath.documentId, isEqualTo: watchlistId)
              .get();

          //return watchlist if it exists
          if (querySnapshot.docs.isNotEmpty) {
            //add watchlist to the list
            watchLists.add(WatchList.fromFirestore(querySnapshot.docs.first));
          }
        }
      }
      return watchLists;
    } catch (e) {
      logger.e(e);
      return watchLists;
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
        if (watchlist != null && !watchlist.isPrivate) {
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

  //functions for invite collaborators
  Future<bool> inviteCollaborator(
      String watchlistId, String watchlistOwner, String userId) async {
    try {
      final user = await _userService.getUser(userId);

      if ((!user!.pendingInvites.containsKey(watchlistOwner) ||
              !user.pendingInvites[watchlistOwner]!.contains(watchlistId)) &&
          (!user.collabWatchlists.containsKey(watchlistOwner) ||
              !user.collabWatchlists[watchlistOwner]!.contains(watchlistId)) &&
          watchlistOwner != userId) {
        await _firestore.collection('users').doc(userId).update({
          'pendingInvites.$watchlistOwner': FieldValue.arrayUnion([watchlistId])
        });
        return true;
      }
    } catch (e) {
      logger.e(e);
      return false;
    }
    return false;
  }

  Future<void> acceptInvite(
      String watchlistId, String watchlistOwner, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'pendingInvites.$watchlistOwner': FieldValue.arrayRemove([watchlistId]),
        'collabWatchlists.$watchlistOwner': FieldValue.arrayUnion([watchlistId])
      });

      await _firestore
          .collection('users')
          .doc(watchlistOwner)
          .collection('my_watchlists')
          .doc(watchlistId)
          .update({
        'collaborators': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> declineInvite(
      String watchlistId, String watchlistOwner, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'pendingInvites.$watchlistOwner': FieldValue.arrayRemove([watchlistId])
      });
    } catch (e) {
      logger.e(e);
    }
  }
}
