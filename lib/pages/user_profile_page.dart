import 'package:flutter/material.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  final MyUser user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late bool isFriend = false;
  bool isLoading = true;
  bool friendStatusChanged = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  Future<void> _checkFriendStatus() async {
    try {
      MyUser? currentUser = await _userService.getCurrentUser();
      if (mounted) {
        setState(() {
          isFriend = currentUser?.friendList.contains(widget.user.id) ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking friend status: $e')),
        );
      }
    }
  }

  Future<void> _toggleFriendStatus() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    try {
      if (isFriend) {
        await _userService.removeFriend(currentUserId, widget.user.id);
      } else {
        await _userService.addFriend(currentUserId, widget.user.id);
      }
      if (mounted) {
        setState(() {
          isFriend = !isFriend;
          isLoading = false;
          friendStatusChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to ${isFriend ? 'remove' : 'add'} friend: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.of(context).pop(friendStatusChanged);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(friendStatusChanged);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _toggleFriendStatus,
                          child:
                              Text(isFriend ? 'Remove Friend' : 'Add Friend'),
                        ),
                  const SizedBox(height: 32),
                  const Text(
                    'Watchlists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey[900],
                    child: const Center(
                      child: Text('Watchlists coming soon!'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
