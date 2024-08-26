import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String id;
  final String username;
  final String name;
  final String email;
  final DateTime? birthdate;
  final String? profilePicture;
  final List<String> favoriteGenres;
  final List<String> friendList;
  final List<String> likedMovies;
  final Map<String, List<String>> customLists;

  MyUser({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.birthdate,
    this.profilePicture,
    this.favoriteGenres = const [],
    this.friendList = const [],
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
      'birthdate': birthdate,
      'profilePicture': profilePicture,
      'favoriteGenres': favoriteGenres,
      'friendList': friendList,
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
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      profilePicture: data['profilePicture'],
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      friendList: List<String>.from(data['friendList'] ?? []),
      likedMovies: List<String>.from(data['likedMovies'] ?? []),
      customLists: Map<String, List<String>>.from(
        (data['customLists'] ?? {})
            .map((key, value) => MapEntry(key, List<String>.from(value))),
      ),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, name: $name, email: $email, birthdate: $birthdate, profilePicture: $profilePicture, favoriteGenres: $favoriteGenres, friendList: $friendList, likedMovies: $likedMovies, customLists: $customLists)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyUser &&
        other.id == id &&
        other.username == username &&
        other.name == name &&
        other.email == email &&
        other.birthdate == birthdate &&
        other.profilePicture == profilePicture &&
        listEquals(other.favoriteGenres, favoriteGenres) &&
        listEquals(other.friendList, friendList) &&
        listEquals(other.likedMovies, likedMovies) &&
        mapEquals(other.customLists, customLists);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        name.hashCode ^
        email.hashCode ^
        birthdate.hashCode ^
        profilePicture.hashCode ^
        favoriteGenres.hashCode ^
        friendList.hashCode ^
        likedMovies.hashCode ^
        customLists.hashCode;
  }
}
