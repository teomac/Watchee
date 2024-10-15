import 'package:flutter/material.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/watchlist.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';

class InviteCollaboratorsPage extends StatefulWidget {
  final WatchList watchlist;

  const InviteCollaboratorsPage({super.key, required this.watchlist});

  @override
  State<InviteCollaboratorsPage> createState() =>
      _InviteCollaboratorsPageState();
}

class _InviteCollaboratorsPageState extends State<InviteCollaboratorsPage> {
  final UserService _userService = UserService();
  final WatchlistService _watchlistService = WatchlistService();
  List<MyUser> _followedUsers = [];
  final List<MyUser> _alreadyInvited = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowedUsers();
  }

  Future<void> _loadFollowedUsers() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        _followedUsers = await _userService.getFollowing(currentUser.id);
        for (final userId in widget.watchlist.collaborators) {
          if (_followedUsers.any((user) => user.id == userId)) {
            //remove it
            _followedUsers.removeWhere((user) => user.id == userId);
          }
        }
      }
    } catch (e) {
      // Handle error (e.g., show a snackbar)
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _inviteCollaborator(MyUser user) async {
    try {
      final result = await _watchlistService.inviteCollaborator(
          widget.watchlist.id, widget.watchlist.userID, user.id);
      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invitation sent to ${user.username}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Invitation already sent to ${user.username}')),
          );
        }
      }
      _alreadyInvited.add(user);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invitation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Collaborators'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followedUsers.isEmpty
              ? const Center(child: Text('No users available to invite'))
              : ListView.builder(
                  itemCount: _followedUsers.length,
                  itemBuilder: (context, index) {
                    final user = _followedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePicture != null
                            ? NetworkImage(user.profilePicture!)
                            : null,
                        child: user.profilePicture == null
                            ? Text(user.username[0].toUpperCase())
                            : null,
                      ),
                      title: Text(user.username),
                      trailing: SizedBox(
                        width: 48, // Fixed width for consistent alignment
                        child: _alreadyInvited.contains(user)
                            ? const Icon(Icons.check, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _inviteCollaborator(user),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
