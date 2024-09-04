import 'dart:io'; // Add this line to import the 'File' class
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Add a friend to user's friend list
  Future<void> addFriend(String userId, String friendId) async {
    await _firestore.collection('users').doc(userId).update({
      'friendList': FieldValue.arrayUnion([friendId])
    });
  }

  // Remove a friend from user's friend list
  Future<void> removeFriend(String userId, String friendId) async {
    await _firestore.collection('users').doc(userId).update({
      'friendList': FieldValue.arrayRemove([friendId])
    });
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

  Future<List<MyUser>> searchUsers(String query) async {
    if (query.length < 3) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '${query}z')
          .limit(20) // Limit the number of results
          .get();

      return querySnapshot.docs
          .map((doc) => MyUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      logger.d('Error searching users: $e');
      return [];
    }
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      logger.d('User signed out');
    } catch (e) {
      logger.d('Failed to sign out: $e');
      return false;
    }
    return true;
  }
}
