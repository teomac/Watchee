import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';

class EditReviewsPage extends StatefulWidget {
  final MyUser user;
  final List<MovieReview> userReviews;

  const EditReviewsPage(
      {super.key, required this.user, required this.userReviews});

  @override
  State<EditReviewsPage> createState() => _EditReviewsPageState();
}

class _EditReviewsPageState extends State<EditReviewsPage> {
  final List<MovieReview> _selectedReviews = [];
  final UserService _userService = UserService();
  MyUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing data: $e')),
        );
      }
    }
  }

  void _toggleSelection(MovieReview review) {
    setState(() {
      if (_selectedReviews.contains(review)) {
        _selectedReviews.remove(review);
      } else {
        _selectedReviews.add(review);
      }
    });
  }

  Future<void> _deleteSelectedReviews() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Text(
              'Are you sure you want to delete ${_selectedReviews.length} review(s)?\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _userService.deleteReviews(_currentUser!.id, _selectedReviews);
        setState(() {
          widget.userReviews
              .removeWhere((review) => _selectedReviews.contains(review));
          _selectedReviews.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Selected reviews deleted successfully.')),
          );
          Navigator.pop(context, widget.userReviews);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete selected reviews: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed:
                _selectedReviews.isNotEmpty ? _deleteSelectedReviews : null,
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: widget.userReviews.length,
          itemBuilder: (context, index) {
            final review = widget.userReviews[index];
            return ListTile(
              leading: Checkbox(
                value: _selectedReviews.contains(review),
                onChanged: (bool? selected) {
                  _toggleSelection(review);
                },
              ),
              title: Text(
                review.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${review.rating}/5',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              isThreeLine: true,
            );
          }),
    );
  }
}
