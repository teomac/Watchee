import 'package:dima_project/models/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/models/user.dart';

class CollaboratorsListPage extends StatefulWidget {
  final WatchList watchlist;

  const CollaboratorsListPage({super.key, required this.watchlist});

  @override
  State<CollaboratorsListPage> createState() => _CollaboratorsListPageState();
}

class _CollaboratorsListPageState extends State<CollaboratorsListPage> {
  final UserService _userService = UserService();
  List<MyUser> _collaborators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  Future<void> _loadCollaborators() async {
    List<MyUser> collaborators = [];
    try {
      if (widget.watchlist.collaborators.isNotEmpty) {
        for (final userId in widget.watchlist.collaborators) {
          final collaborator = await _userService.getUser(userId);
          if (collaborator != null) {
            collaborators.add(collaborator);
          }
        }
      }
      setState(() {
        _collaborators = collaborators;
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
        title: const Text('Collaborators'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _collaborators.length,
              itemBuilder: (context, index) {
                final collaborator = _collaborators[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: collaborator.profilePicture != null
                        ? NetworkImage(collaborator.profilePicture!)
                        : null,
                    child: collaborator.profilePicture == null
                        ? Text(collaborator.username[0].toUpperCase())
                        : null,
                  ),
                  title: Text(collaborator.username),
                  subtitle: Text(collaborator.name),
                  onTap: () {
                    // Navigate to user profile
                  },
                );
              },
            ),
    );
  }
}
