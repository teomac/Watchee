import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:dima_project/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

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
}
