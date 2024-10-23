import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/movie_review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([DocumentSnapshot])
import 'movie_review_test.mocks.dart';

void main() {
  group('MovieReview', () {
    test('fromFirestore creates MovieReview object correctly', () {
      final mockSnapshot = MockDocumentSnapshot();

      when(mockSnapshot.data()).thenReturn({
        'userId': 'user123',
        'movieId': 1,
        'text': 'Great movie!',
        'rating': 5,
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'title': 'Test Movie',
        'username': 'testuser'
      });
      when(mockSnapshot.id).thenReturn('testId');

      final review = MovieReview.fromFirestore(mockSnapshot);

      expect(review.id, 'testId');
      expect(review.userId, 'user123');
      expect(review.movieId, 1);
      expect(review.text, 'Great movie!');
      expect(review.rating, 5);
      expect(review.timestamp, isA<Timestamp>());
      expect(review.title, 'Test Movie');
      expect(review.username, 'testuser');
    });

    test('toMap converts MovieReview object to Map correctly', () {
      final review = MovieReview(
        id: 'review123',
        userId: 'user123',
        movieId: 1,
        text: 'Great movie!',
        rating: 5,
        timestamp: Timestamp.fromDate(DateTime(2023, 1, 1)),
        title: 'Test Movie',
        username: 'testuser',
      );

      final map = review.toMap();

      expect(map['id'], 'review123');
      expect(map['userId'], 'user123');
      expect(map['movieId'], 1);
      expect(map['text'], 'Great movie!');
      expect(map['rating'], 5);
      expect(map['timestamp'], isA<Timestamp>());
      expect(map['title'], 'Test Movie');
      expect(map['username'], 'testuser');
    });
  });
}
