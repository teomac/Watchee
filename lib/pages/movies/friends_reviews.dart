import 'package:dima_project/models/movie_review.dart';
import 'package:flutter/material.dart';

class FriendsReviews extends StatelessWidget {
  final List<MovieReview> friendsReviews;

  const FriendsReviews({required this.friendsReviews, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends Reviews'),
      ),
      body: ListView.builder(
        itemCount: friendsReviews.length,
        itemBuilder: (context, index) {
          final review = friendsReviews[index];
          return ListTile(
            leading: CircleAvatar(
              child:
                  Text(review.username.isNotEmpty ? review.username[0] : '?'),
            ),
            title: Text(review.username),
            subtitle: Text(review.text),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(review.rating.toStringAsFixed(1)),
              ],
            ),
          );
        },
      ),
    );
  }
}
