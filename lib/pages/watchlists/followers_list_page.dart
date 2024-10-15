import 'package:dima_project/models/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/models/user.dart';

class FollowersListPage extends StatefulWidget {
  final WatchList watchlist;

  const FollowersListPage({super.key, required this.watchlist});

  @override
  State<FollowersListPage> createState() => _FollowersListPageState();
}

class _FollowersListPageState extends State<FollowersListPage> {
  final UserService _userService = UserService();
  List<MyUser> _followers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    List<MyUser> followers = [];
    try {
      if (widget.watchlist.followers.isNotEmpty) {
        for (final followerId in widget.watchlist.followers) {
          final follower = await _userService.getUser(followerId);
          if (follower != null) {
            followers.add(follower);
          }
        }
      }
      setState(() {
        _followers = followers;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _followers.length,
              itemBuilder: (context, index) {
                final follower = _followers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: follower.profilePicture != null
                        ? NetworkImage(follower.profilePicture!)
                        : null,
                    child: follower.profilePicture == null
                        ? Text(follower.username[0].toUpperCase())
                        : null,
                  ),
                  title: Text(follower.username),
                  subtitle: Text(follower.name),
                  onTap: () {
                    // Navigate to user profile
                  },
                );
              },
            ),
    );
  }
}
