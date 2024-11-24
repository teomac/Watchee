import 'package:dima_project/models/movie_review.dart';
import 'package:dima_project/pages/account/edit_reviews_page.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/pages/watchlists/manage_watchlist_page.dart';
import 'package:provider/provider.dart';

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
  MyUser? _currentUser;
  List<MyUser> _followedByUsers = [];
  List<MovieReview> _userReviews = [];
  bool _showAllReviews = false;
  List<WatchList> _publicWatchlists = [];
  bool _isLoadingWatchlists = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final userServices = Provider.of<UserService>(context, listen: false);
      final currentUser = await userServices.getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
        await Future.wait([
          _checkFollowStatus(),
          _fetchFollowedByUsers(),
          _fetchUserReviews(),
          _fetchPublicWatchlists(),
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
    bool followStatus = await Provider.of<UserService>(context, listen: false)
        .isFollowing(_currentUser!.id, widget.user.id);
    if (mounted) {
      setState(() {
        isFollowing = followStatus;
      });
    }
  }

  Future<void> _fetchFollowedByUsers() async {
    if (_currentUser == null) return;
    List<MyUser> followers =
        await Provider.of<UserService>(context, listen: false)
            .getFollowers(widget.user.id);
    _followedByUsers = followers
        .where((follower) =>
            _currentUser!.following.contains(follower.id) &&
            follower.id != _currentUser!.id)
        .toList();
  }

  Future<void> _toggleFollowStatus() async {
    final userService = Provider.of<UserService>(context, listen: false);
    if (!mounted || _currentUser == null) return;
    try {
      setState(() {
        isFollowing = !isFollowing;
      });

      if (isFollowing) {
        await userService.followUser(_currentUser!.id, widget.user.id);
      } else {
        await userService.unfollowUser(_currentUser!.id, widget.user.id);
      }

      if (mounted) {
        setState(() {
          followStatusChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to ${isFollowing ? 'unfollow' : 'follow'} user: $e')),
        );
      }
    }
  }

  Future<void> _fetchUserReviews() async {
    if (_currentUser == null) return;
    List<MovieReview> reviews =
        await Provider.of<UserService>(context, listen: false)
            .getReviewsByUser(widget.user.id);
    if (mounted) {
      setState(() {
        _userReviews = reviews;
      });
    }
  }

  Future<void> _fetchPublicWatchlists() async {
    if (_currentUser == null) return;
    try {
      List<WatchList> watchlists =
          await Provider.of<WatchlistService>(context, listen: false)
              .getPublicWatchLists(widget.user.id);
      if (mounted) {
        setState(() {
          _publicWatchlists = watchlists;
          _isLoadingWatchlists = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch public watchlists: $e')),
        );
        setState(() {
          _isLoadingWatchlists = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
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
                  padding: const EdgeInsets.all(16.0),
                  child: !isTablet
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(height: 14),
                            _buildFollowButton(),
                            if (_followedByUsers.isNotEmpty)
                              _buildFollowedByText(),
                            const SizedBox(height: 32),
                            _buildPublicWatchlists(),
                            const SizedBox(height: 32),
                            _buildLatestReviews(),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProfileHeader(),
                            const SizedBox(height: 14),
                            _buildFollowButton(),
                            if (_followedByUsers.isNotEmpty)
                              _buildFollowedByText(),
                            const SizedBox(height: 32),
                            _buildTabletLayout(),
                          ],
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPublicWatchlists(isTablet: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLatestReviews(isTablet: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: widget.user.profilePicture != null
              ? NetworkImage(widget.user.profilePicture!)
              : null,
          child: widget.user.profilePicture == null
              ? const Icon(
                  Icons.person,
                  size: 60,
                )
              : null,
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
              ?.copyWith(color: colorScheme.secondary),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    final theme = Theme.of(context).colorScheme;

    if (_currentUser == null || _currentUser!.id == widget.user.id) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(110, 44),
        foregroundColor: theme.primary,
        backgroundColor: theme.surface,
        side: BorderSide(
          color: theme.primary,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: _toggleFollowStatus,
      child: Text(isFollowing ? 'Unfollow' : 'Follow',
          style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildFollowedByText() {
    final colorScheme = Theme.of(context).colorScheme;

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
            ?.copyWith(color: colorScheme.secondary),
      ),
    );
  }

  Widget _buildPublicWatchlists({bool isTablet = false}) {
    return Column(
      crossAxisAlignment:
          isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'Public Watchlists',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: isTablet ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 8),
        _isLoadingWatchlists
            ? const Center(child: CircularProgressIndicator())
            : _publicWatchlists.isEmpty
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Text('No public watchlists available.')))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _publicWatchlists.length,
                    itemBuilder: (context, index) {
                      final watchlist = _publicWatchlists[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.primaries[index % Colors.primaries.length],
                          child: Text(watchlist.name[0].toUpperCase()),
                        ),
                        title: Text(watchlist.name),
                        subtitle: Text('${watchlist.movies.length} movies'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageWatchlistPage(
                                userId: watchlist.userID,
                                watchlistId: watchlist.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ],
    );
  }

  Widget _buildLatestReviews({bool isTablet = false}) {
    return Column(
      crossAxisAlignment:
          isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Center(
            child: !isTablet
                ? Row(
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      ),
                      if (_currentUser != null &&
                          _currentUser!.id == widget.user.id &&
                          _userReviews.isNotEmpty)
                        TextButton(
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _openEditReviewsPage,
                          child: const Icon(Icons.edit, size: 22),
                        ),
                    ],
                  )
                : Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  )),
        if (isTablet &&
            _currentUser != null &&
            _currentUser!.id == widget.user.id &&
            _userReviews.isNotEmpty)
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _openEditReviewsPage,
            child: const Icon(Icons.edit, size: 22),
          ),
        const SizedBox(height: 8),
        if (_userReviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('No reviews yet.'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _showAllReviews
                ? _userReviews.length
                : (_userReviews.length <= 3 ? _userReviews.length : 3),
            itemBuilder: (context, index) {
              final review = _userReviews[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(
                    review.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    review.text,
                    style: const TextStyle(fontSize: 15),
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
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        if (_userReviews.length > 2)
          Align(
            alignment: isTablet ? Alignment.center : Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllReviews = !_showAllReviews;
                });
              },
              child: Text(_showAllReviews ? 'Show less' : 'Show more',
                  style: const TextStyle(fontSize: 16)),
            ),
          )
      ],
    );
  }

  void _openEditReviewsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewsPage(
          user: widget.user,
          userReviews: _userReviews,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }
}
