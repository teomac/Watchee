import 'dart:io'; // Add this line to import the 'File' class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:dima_project/models/user_model.dart';
import 'package:logger/logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final Logger logger = Logger();

  // Create a new user in Firestore
  Future<void> createUser(MyUser user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Get user data from Firestore
  Future<MyUser?> getUser(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.exists ? MyUser.fromFirestore(doc) : null;
  }

  // Update user data in Firestore
  Future<void> updateUser(MyUser user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Follow a user
  Future<void> followUser(String currentUserId, String userToFollowId) async {
    // Add userToFollowId to current user's following list
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayUnion([userToFollowId])
    });

    // Add currentUserId to userToFollow's followers list
    await _firestore.collection('users').doc(userToFollowId).update({
      'followers': FieldValue.arrayUnion([currentUserId])
    });
  }

  // Unfollow a user
  Future<void> unfollowUser(
      String currentUserId, String userToUnfollowId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'following': FieldValue.arrayRemove([userToUnfollowId])
    });

    await _firestore.collection('users').doc(userToUnfollowId).update({
      'followers': FieldValue.arrayRemove([currentUserId])
    });

    logger.d('User $currentUserId unfollowed $userToUnfollowId');
  }

  Future<void> removeFollower(
      String currentUserId, String followerToRemoveId) async {
    await _firestore.collection('users').doc(currentUserId).update({
      'followers': FieldValue.arrayRemove([followerToRemoveId])
    });

    await _firestore.collection('users').doc(followerToRemoveId).update({
      'following': FieldValue.arrayRemove([currentUserId])
    });

    logger.d('User $currentUserId removed follower $followerToRemoveId');
  }

  // Get followers of a user
  Future<List<MyUser>> getFollowers(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    MyUser user = MyUser.fromFirestore(userDoc);
    List<String> followerIds = List<String>.from(user.followers);

    //for followers in followerIds retrieve the user data
    List<MyUser> followersList = [];
    for (String followerId in followerIds) {
      MyUser follower = await getUser(followerId).then((value) => value!);
      followersList.add(follower);
    }

    return followersList;
  }

  // Get users followed by a user
  Future<List<MyUser>> getFollowing(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    MyUser user = MyUser.fromFirestore(userDoc);
    List<String> followingIds = List<String>.from(user.following);

    // Retrieve user data for each user ID in followingIds
    List<MyUser> followingList = [];
    for (String id in followingIds) {
      MyUser following = await getUser(id).then((value) => value!);
      followingList.add(following);
    }

    return followingList;
  }

  // Check if a user is following another user
  Future<bool> isFollowing(String currentUserId, String otherUserId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUserId).get();
    List<String> following = List<String>.from(userDoc['following'] ?? []);
    return following.contains(otherUserId);
  }

  // Search for users
  Future<List<MyUser>> searchUsers(String query) async {
    query = query.toLowerCase();
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .get();

    return snapshot.docs.map((doc) => MyUser.fromFirestore(doc)).toList();
  }

  // Get current logged-in user
  Future<MyUser?> getCurrentUser() async {
    auth.User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await getUser(firebaseUser.uid);
    }
    return null;
  }

  // Add a movie to user's liked movies
  Future<void> addLikedMovie(String userId, String movieId) async {
    await _firestore.collection('users').doc(userId).update({
      'likedMovies': FieldValue.arrayUnion([movieId])
    });
  }

  // Remove a movie from user's liked movies
  Future<void> removeLikedMovie(String userId, String movieId) async {
    await _firestore.collection('users').doc(userId).update({
      'likedMovies': FieldValue.arrayRemove([movieId])
    });
  }

  // Add a custom movie list
  Future<void> addCustomList(
      String userId, String listName, List<String> movies) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'customLists.$listName': movies});
  }

  // Remove a custom movie list
  Future<void> removeCustomList(String userId, String listName) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'customLists.$listName': FieldValue.delete()});
  }

  // Get a unique username based on a base username
  Future<String> getUniqueUsername(String baseUsername) async {
    String username =
        baseUsername.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    int suffix = 1;
    bool isUnique = false;

    try {
      while (!isUnique) {
        // Query the 'users' collection for documents where 'username' matches the current username
        QuerySnapshot usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1) // Limit to 1 result for efficiency
            .get();

        if (usernameQuery.docs.isEmpty) {
          // If no documents are found, the username is unique
          isUnique = true;
          return username;
        } else {
          // If the username exists, append a number and try again
          username = '$baseUsername$suffix';
          suffix++;
        }
      }
    } catch (e) {
      logger.d("Error querying Firestore for usernames: $e");
      // Fallback: use a timestamp to ensure uniqueness
      username = '${baseUsername}_${DateTime.now().millisecondsSinceEpoch}';
      logger
          .d("Warning: Unable to verify username uniqueness. Using $username");
    }

    return username;
  }

  // Upload an image to Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      final String uid = _auth.currentUser!.uid;
      final String fileName = '$uid.png';
      final Reference ref =
          FirebaseStorage.instance.ref('profile_pictures').child(fileName);

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      logger.d('Failed to upload image: $e');
      return null;
    }
  }

  // add a new movie review
  Future<void> addMovieReview(String userId, int movieId, int rating,
      String text, String title, String username) async {
    final review = MovieReview(
        id: _firestore.collection('reviews').doc().id,
        userId: userId,
        movieId: movieId,
        text: text,
        rating: rating,
        timestamp: Timestamp.now(),
        title: title,
        username: username);

    await _firestore.collection('reviews').doc(review.id).set(review.toMap());
  }

  // retrieve the two most recent reviews for a movie
  Future<List<MovieReview>> getReviewsForMovie(String movieId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .orderBy('timestamp', descending: true)
        .limit(2)
        .get();

    return snapshot.docs.map((doc) => MovieReview.fromFirestore(doc)).toList();
  }

  // retrieve reviews for a user
  Future<List<MovieReview>> getReviewsByUser(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => MovieReview.fromFirestore(doc)).toList();
  }

  // retrieve friends reviews
  Future<List<MovieReview>> getFriendsReviews(
      String currentUserId, int movieId) async {
    try {
      // retrieve followed users
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      MyUser user = MyUser.fromFirestore(userDoc);
      List<String> followedUserIds = List<String>.from(user.following);

      // retrieve all reviews from followed users
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('userId', whereIn: followedUserIds)
          .where('movieId', isEqualTo: movieId)
          .orderBy('timestamp', descending: true)
          .limit(2)
          .get();

      return reviewsSnapshot.docs
          .map((doc) => MovieReview.fromFirestore(doc))
          .toList();
    } catch (e) {
      logger.d('Failed to retrieve friends reviews: $e');
      return [];
    }
  }

  // add movie to liked movies
  Future<void> addToLikedMovies(String userId, int movieId) async {
    await _firestore.collection('users').doc(userId).update({
      'likedMovies': FieldValue.arrayUnion([movieId])
    });
  }

  // remove movie from liked movies
  Future<void> removeFromLikedMovies(String userId, int movieId) async {
    await _firestore.collection('users').doc(userId).update({
      'likedMovies': FieldValue.arrayRemove([movieId])
    });
  }

  // check if movie is in liked movies
  Future<bool> checkLikedMovies(String userId, int movieId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    List<dynamic> likedMovies = userDoc['likedMovies'];
    if (likedMovies == null) return false;
    return likedMovies.contains(movieId);
  }

  // delete reviews
  Future<void> deleteReviews(String userId, List<MovieReview> reviews) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (var review in reviews) {
        if (review.userId == userId) {
          DocumentReference reviewRef =
              _firestore.collection('reviews').doc(review.id);
          batch.delete(reviewRef);
        }
      }
      await batch.commit();
      logger
          .d('Successfully deleted ${reviews.length} reviews for user $userId');
    } catch (e) {
      logger.e('Failed to delete reviews: $e');
      throw Exception('Failed to delete reviews $e');
    }
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      logger.d('User signed out');
      return true;
    } catch (e) {
      logger.d('Failed to sign out: $e');
      return false;
    }
  }
}
