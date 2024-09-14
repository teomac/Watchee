import 'package:cloud_firestore/cloud_firestore.dart';

class WatchList {
  final String id;
  final String userID;
  final String name;
  final bool isPrivate;
  final Map<int, bool> movies;
  final List<String> followers;
  final List<String> collaborators;

  WatchList({
    required this.id,
    required this.userID,
    required this.name,
    required this.isPrivate,
    this.movies = const {},
    this.followers = const [],
    this.collaborators = const [],
  });

  // Convert WatchList object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userID': userID,
      'name': name,
      'isPrivate': isPrivate,
      'movies': movies,
      'followers': followers,
      'collaborators': collaborators,
    };
  }

  // Create WatchList object from Firestore document
  factory WatchList.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return WatchList(
      id: doc.id,
      userID: data['userID'] ?? '',
      name: data['name'] ?? '',
      isPrivate: data['isPrivate'] ?? true,
      movies: Map<int, bool>.from(data['movies'] ?? {}),
      followers: List<String>.from(data['followers'] ?? []),
      collaborators: List<String>.from(data['collaborators'] ?? []),
    );
  }

  @override
  String toString() {
    return 'WatchList{id: $id, userID: $userID, isPrivate: $isPrivate, movies: $movies, followers: $followers, collaborators: $collaborators}';
  }

  // Copy the WatchList object with new data
  WatchList copyWith({
    String? id,
    String? userID,
    String? name,
    bool? isPrivate,
    Map<int, bool>? movies,
    List<String>? followers,
    List<String>? collaborators,
  }) {
    return WatchList(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      name: name ?? this.name,
      isPrivate: isPrivate ?? this.isPrivate,
      movies: movies ?? this.movies,
      followers: followers ?? this.followers,
      collaborators: collaborators ?? this.collaborators,
    );
  }
}
