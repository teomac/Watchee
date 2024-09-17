import 'package:dima_project/models/movie_review.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';

class UserProfilePage extends StatefulWidget {
  final MyUser user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late bool isFollowing = false;
  bool isLoading = true;
  bool followStatusChanged = false;
  final UserService _userService = UserService();
  MyUser? _currentUser;
  List<MyUser> _followedByUsers = [];
  List<MovieReview> _userReviews = [];
  bool _showAllReviews = false;

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
        await Future.wait([
          _checkFollowStatus(),
          _fetchFollowedByUsers(),
          _fetchUserReviews(),
        ]);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing data: $e')),
        );
      }
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_currentUser == null) return;
    bool followStatus =
        await _userService.isFollowing(_currentUser!.id, widget.user.id);
    if (mounted) {
      setState(() {
        isFollowing = followStatus;
      });
    }
  }

  Future<void> _fetchFollowedByUsers() async {
    if (_currentUser == null) return;
    List<MyUser> followers = await _userService.getFollowers(widget.user.id);
    _followedByUsers = followers
        .where((follower) =>
            _currentUser!.following.contains(follower.id) &&
            follower.id != _currentUser!.id)
        .toList();
  }

  Future<void> _toggleFollowStatus() async {
    if (!mounted || _currentUser == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      if (isFollowing) {
        await _userService.unfollowUser(_currentUser!.id, widget.user.id);
      } else {
        await _userService.followUser(_currentUser!.id, widget.user.id);
      }
      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
          followStatusChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to ${isFollowing ? 'unfollow' : 'follow'} user: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserReviews() async {
    if (_currentUser == null) return;
    List<MovieReview> reviews =
        await _userService.getReviewsByUser(widget.user.id);
    if (mounted) {
      setState(() {
        _userReviews = reviews;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(followStatusChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.username),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(followStatusChanged),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 14),
                      _buildFollowButton(),
                      if (_followedByUsers.isNotEmpty) _buildFollowedByText(),
                      const SizedBox(height: 32),
                      _buildPublicWatchlists(),
                      const SizedBox(height: 32),
                      _buildLatestReviews(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: widget.user.profilePicture != null
              ? NetworkImage(widget.user.profilePicture!)
              : const AssetImage('lib/images/default_profile.jpg')
                  as ImageProvider,
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '@${widget.user.username}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    if (_currentUser == null || _currentUser!.id == widget.user.id) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: _toggleFollowStatus,
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }

  Widget _buildFollowedByText() {
    String followedByText = 'Followed by ${_followedByUsers.first.name}';
    if (_followedByUsers.length > 1) {
      followedByText += ' and ${_followedByUsers.length - 1} others';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        followedByText,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildPublicWatchlists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Public Watchlists',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          color: Colors.grey[900],
          child: const Center(
            child: Text('Public watchlists coming soon!'),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestReviews() {
    if (_userReviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Text('No reviews yet.'),
      );
    }

    int reviewsToShow = 0;
    if (_userReviews.length <= 2) {
      reviewsToShow = _userReviews.length;
    } else {
      reviewsToShow = _showAllReviews ? _userReviews.length : 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviewsToShow,
          itemBuilder: (context, index) {
            final review = _userReviews[index];
            return ListTile(
              title: Text(
                (review.title),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                review.text,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${review.rating}/5',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  )
                ],
              ),
              isThreeLine: true,
            );
          },
        ),
        if (_userReviews.length > 2)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllReviews = !_showAllReviews;
              });
            },
            child: Text(_showAllReviews ? 'Show less' : 'Show more'),
          ),
      ],
    );
  }
}
