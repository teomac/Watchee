import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final String? profilePicture;
  final List<String>? nameLowerCase;
  final List<String> favoriteGenres;
  final List<String> following; // Changed from friendList
  final List<String> followers; // New field
  final List<int> likedMovies;
  final List<int> seenMovies;
  final Map<String, List<dynamic>> followedWatchlists;
  final Map<String, List<dynamic>> pendingInvites;
  final Map<String, List<dynamic>> collabWatchlists;

  MyUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.nameLowerCase,
    this.profilePicture,
    this.favoriteGenres = const [],
    this.following = const [], // Changed from friendList
    this.followers = const [], // New field
    this.likedMovies = const [],
    this.seenMovies = const [],
    this.followedWatchlists = const {},
    this.pendingInvites = const {},
    this.collabWatchlists = const {},
  });

  // Convert User object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'nameLowerCase': nameLowerCase,
      'profilePicture': profilePicture,
      'favoriteGenres': favoriteGenres,
      'following': following, // Changed from friendList
      'followers': followers, // New field
      'likedMovies': likedMovies,
      'seenMovies': seenMovies,
      'followedWatchlists': followedWatchlists,
      'pendingInvites': pendingInvites,
      'collabWatchlists': collabWatchlists,
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
      nameLowerCase: List<String>.from(data['nameLowerCase'] ?? []),
      profilePicture: data['profilePicture'],
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      following:
          List<String>.from(data['following'] ?? []), // Changed from friendList
      followers: List<String>.from(data['followers'] ?? []), // New field
      likedMovies: List<int>.from(data['likedMovies'] ?? []),
      seenMovies: List<int>.from(data['seenMovies'] ?? []),
      followedWatchlists:
          Map<String, List<dynamic>>.from(data['followedWatchlists'] ?? {}),
      pendingInvites:
          Map<String, List<dynamic>>.from(data['pendingInvites'] ?? {}),
      collabWatchlists:
          Map<String, List<dynamic>>.from(data['collabWatchlists'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'MyUser(id: $id, username: $username, name: $name, email: $email, nameLowerCase: $nameLowerCase, profilePicture: $profilePicture, favoriteGenres: $favoriteGenres, following: $following, followers: $followers, likedMovies: $likedMovies, seenMovies: $seenMovies, followedWatchlists: $followedWatchlists, pendingInvites: $pendingInvites, collabWatchlists: $collabWatchlists)';
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
        listEquals(nameLowerCase, nameLowerCase) &&
        listEquals(other.favoriteGenres, favoriteGenres) &&
        listEquals(other.following, following) &&
        listEquals(other.followers, followers) &&
        listEquals(other.likedMovies, likedMovies) &&
        listEquals(other.seenMovies, seenMovies) &&
        mapEquals(other.followedWatchlists, followedWatchlists) &&
        mapEquals(other.pendingInvites, pendingInvites) &&
        mapEquals(other.collabWatchlists, collabWatchlists);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        nameLowerCase.hashCode ^
        profilePicture.hashCode ^
        favoriteGenres.hashCode ^
        following.hashCode ^
        followers.hashCode ^
        likedMovies.hashCode ^
        seenMovies.hashCode ^
        followedWatchlists.hashCode ^
        pendingInvites.hashCode ^
        collabWatchlists.hashCode;
  }
}
