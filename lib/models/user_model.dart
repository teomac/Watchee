import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? profilePicture;
  final List<String> favoriteGenres;
  final List<String> following; // Changed from friendList
  final List<String> followers; // New field
  final List<dynamic> likedMovies;
  final Map<String, List<String>> customLists;

  MyUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.profilePicture,
    this.favoriteGenres = const [],
    this.following = const [], // Changed from friendList
    this.followers = const [], // New field
    this.likedMovies = const [],
    this.customLists = const {},
  });

  // Convert User object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'favoriteGenres': favoriteGenres,
      'following': following, // Changed from friendList
      'followers': followers, // New field
      'likedMovies': likedMovies,
      'customLists': customLists,
    };
  }

  // Create User object from Firestore document
  factory MyUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MyUser(
      id: doc.id,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'],
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      following:
          List<String>.from(data['following'] ?? []), // Changed from friendList
      followers: List<String>.from(data['followers'] ?? []), // New field
      likedMovies: List<dynamic>.from(data['likedMovies'] ?? []),
      customLists: Map<String, List<String>>.from(
        (data['customLists'] ?? {})
            .map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
    );
  }

  @override
  String toString() {
    return 'MyUser(id: $id, username: $username, name: $name, email: $email, profilePicture: $profilePicture, favoriteGenres: $favoriteGenres, following: $following, followers: $followers, likedMovies: $likedMovies, customLists: $customLists)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyUser &&
        other.id == id &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        listEquals(other.favoriteGenres, favoriteGenres) &&
        listEquals(other.following, following) &&
        listEquals(other.followers, followers) &&
        listEquals(other.likedMovies, likedMovies) &&
        mapEquals(other.customLists, customLists);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        favoriteGenres.hashCode ^
        following.hashCode ^
        followers.hashCode ^
        likedMovies.hashCode ^
        customLists.hashCode;
  }
}
