import 'package:flutter/material.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:dima_project/pages/login_and_register/genre_selection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  File? _image;
  var logger = Logger();
  bool permissionGranted = false;
  bool _isUsernameAvailable = true;
  bool _isTooShort = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() => _image = File(pickedImage.path));
      logger.d("Image selected: ${_image!.path}");
    } else {
      logger.d("No image selected");
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    final userService = Provider.of<UserService>(context, listen: false);

    if (username.length < 3) {
      setState(() {
        _isTooShort = true;
        _isUsernameAvailable = false;
      });
      return;
    }
    bool isAvailable = await userService.isUsernameAvailable(username);
    setState(() {
      _isUsernameAvailable = isAvailable;
      _isTooShort = false;
    });
  }

  void _submitForm() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);

    if (_controllerName.text.trim().isEmpty ||
        _controllerUsername.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (_isTooShort) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Username must be at least 3 characters long')),
      );
      return;
    }

    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is not available')),
      );
      return;
    }
    late BuildContext dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String uid = auth.currentUser!.uid;
      String? profilePictureUrl;

      if (_image != null) {
        logger.d("Starting image upload");
        profilePictureUrl = await userService.uploadImage(_image!);
        logger.d("Image upload completed. URL: $profilePictureUrl");
      }

      logger.d("Updating user document for UID: $uid");
      await firestore.collection('users').doc(uid).update({
        'name': _controllerName.text,
        'username': _controllerUsername.text,
        if (profilePictureUrl != null) 'profilePicture': profilePictureUrl,
      });

      await userService.updateUserWithNameLowerCase(uid, _controllerName.text);

      logger.d("User document updated successfully");

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop(); // Dismiss the loading indicator
      }

      if (mounted) {
        // Navigate to the genre selection page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const GenreSelectionPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      logger.e('Error in _submitForm: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss the loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDarkmode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.person,
                                size: 60,
                                color: isDarkmode ? Colors.white : Colors.black)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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
                                    color: isDarkmode
                                        ? Colors.white
                                        : Colors.black,
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
                ),
                const SizedBox(height: 40),
                MyTextField(
                  controller: _controllerName,
                  title: 'Name *',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _controllerUsername,
                  title: 'Username *',
                  obscureText: false,
                  suffixIcon: _isUsernameAvailable
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.close, color: Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  _isUsernameAvailable
                      ? 'Username is available'
                      : !_isTooShort
                          ? 'Username is not available'
                          : 'Username must be at least 3 characters long',
                  style: TextStyle(
                    color: _isUsernameAvailable ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 35),
                CustomSubmitButton(
                  key: const Key('next_button'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  text: 'Next',
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controllerUsername.addListener(() {
      _checkUsernameAvailability(_controllerUsername.text);
    });
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerUsername.dispose();
    super.dispose();
  }
}
