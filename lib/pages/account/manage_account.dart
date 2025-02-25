import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:provider/provider.dart';

class ManageAccountPage extends StatefulWidget {
  final VoidCallback? onFavoriteGenresUpdated;
  const ManageAccountPage({super.key, this.onFavoriteGenresUpdated});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late Future<MyUser?> _userFuture;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<String> _selectedGenres = [];
  final List<String> _allGenres = [
    'Action',
    'Adventure',
    'Animation',
    ' Comedy',
    'Crime',
    'Documentary',
    'Drama',
    ' Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'TV Movie',
    'War',
    'Western'
  ];

  @override
  void initState() {
    super.initState();
    _userFuture =
        Provider.of<UserService>(context, listen: false).getCurrentUser();
    _userFuture.then((user) {
      if (user != null) {
        _usernameController.text = user.username;
        _nameController.text = user.name;

        _selectedGenres = List<String>.from(user.favoriteGenres);
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);

    if (_usernameController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    if (_usernameController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username must be at least 3 characters long')),
      );
      return;
    }

    bool isUsernameAvailable =
        await userService.isUsernameAvailable(_usernameController.text);

    MyUser? currentUser = await userService.getCurrentUser();
    if (currentUser != null &&
        currentUser.username == _usernameController.text) {
      isUsernameAvailable = true;
    }
    if (!isUsernameAvailable) {
      //display snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected username is not available')),
        );
        return;
      }
    }
    try {
      final String uid = auth.currentUser!.uid;
      Map<String, dynamic> updateData = {
        'username': _usernameController.text,
        'name': _nameController.text,
        'favoriteGenres': _selectedGenres,
      };

      if (_image != null) {
        String? imageUrl = await userService.uploadImage(_image!);
        if (imageUrl != null) {
          updateData['profilePicture'] = imageUrl;
        }
      }

      await firestore.collection('users').doc(uid).update(updateData);

      await userService.updateUsernameInReviews(uid, _usernameController.text);

      await userService.updateUserWithNameLowerCase(uid, _nameController.text);

      if (widget.onFavoriteGenresUpdated != null) {
        widget.onFavoriteGenresUpdated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }

      // Refresh user data
      setState(() {
        _userFuture = userService.getCurrentUser();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkmode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Account'),
      ),
      body: FutureBuilder<MyUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (user.profilePicture != null
                              ? NetworkImage(user.profilePicture!)
                              : null) as ImageProvider?,
                      child: (_image == null && user.profilePicture == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 20,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,
                              color: isDarkmode ? Colors.white : Colors.black,
                              size: 20),
                          style: ButtonStyle(
                            //insert border color
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(
                                  color:
                                      isDarkmode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.email, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 36),
                const Text('Favorite Genres',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  children: _allGenres.map((String genre) {
                    return FilterChip(
                      label: Text(genre),
                      selected: _selectedGenres.contains(genre),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenres.add(genre);
                          } else {
                            _selectedGenres.remove(genre);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(240, 44),
                    foregroundColor: theme.primary,
                    backgroundColor: theme.surface,
                    side: BorderSide(
                      color: theme.primary,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
