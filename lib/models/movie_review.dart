import 'package:cloud_firestore/cloud_firestore.dart';

class MovieReview {
  final String id;
  final String userId;
  final int movieId;
  final String text;
  final int rating;
  final Timestamp timestamp;
  final String title;
  final String username;

  MovieReview({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.text,
    required this.rating,
    required this.timestamp,
    required this.title,
    required this.username,
  }) : assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5');

  static MovieReview fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MovieReview(
      id: doc.id,
      userId: data['userId'],
      movieId: data['movieId'],
      rating: data['rating'],
      text: data['text'],
      timestamp: data['timestamp'],
      title: data['title'],
      username: data['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'rating': rating,
      'text': text,
      'timestamp': timestamp,
      'title': title,
      'username': username,
    };
  }
}
