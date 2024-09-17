import 'package:cloud_firestore/cloud_firestore.dart';

class WatchList {
  final String id;
  final String userID;
  final String name;
  final bool isPrivate;
  final List<int> movies;
  final List<String> followers;
  final List<String> collaborators;
  final String createdAt;
  final String updatedAt;

  WatchList({
    required this.id,
    required this.userID,
    required this.name,
    required this.isPrivate,
    this.movies = const [],
    this.followers = const [],
    this.collaborators = const [],
    required this.createdAt,
    required this.updatedAt,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
      movies: List<int>.from(data['movies'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
      collaborators: List<String>.from(data['collaborators'] ?? []),
      createdAt: data['createdAt'] ?? DateTime.now().toString(),
      updatedAt: data['updatedAt'] ?? DateTime.now().toString(),
    );
  }

  @override
  String toString() {
    return 'WatchList{id: $id, userID: $userID, isPrivate: $isPrivate, movies: $movies, followers: $followers, collaborators: $collaborators, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  // Copy the WatchList object with new data
  WatchList copyWith({
    String? id,
    String? userID,
    String? name,
    bool? isPrivate,
    List<int>? movies,
    List<String>? followers,
    List<String>? collaborators,
    String? createdAt,
    String? updatedAt,
  }) {
    return WatchList(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      name: name ?? this.name,
      isPrivate: isPrivate ?? this.isPrivate,
      movies: movies ?? this.movies,
      followers: followers ?? this.followers,
      collaborators: collaborators ?? this.collaborators,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
