import 'package:cloud_firestore/cloud_firestore.dart';

class MovieReview {
  final String id;
  final String userId;
  final int movieId;
  final String text;
  final int rating;
  final Timestamp timestamp;

  MovieReview({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.text,
    required this.rating,
    required this.timestamp,
  });

  static MovieReview fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MovieReview(
      id: doc.id,
      userId: data['userId'],
      movieId: data['movieId'],
      rating: data['rating'],
      text: data['reviewText'],
      timestamp: data['timestamp'],
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
    };
  }
}
