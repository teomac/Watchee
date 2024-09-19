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

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _controllerName = TextEditingController();
  File? _image;
  var logger = Logger();
  bool permissionGranted = false;

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

  void _submitForm() async {
    if (_controllerName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in name field')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String? profilePictureUrl;

      // Only attempt to upload image if one has been selected
      if (_image != null) {
        logger.d("Starting image upload");
        profilePictureUrl = await UserService().uploadImage(_image!);
        logger.d("Image upload completed. URL: $profilePictureUrl");
      }

      logger.d("Updating user document for UID: $uid");
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _controllerName.text,
        if (profilePictureUrl != null) 'profilePicture': profilePictureUrl,
      });

      await UserService()
          .updateUserWithNameLowerCase(uid, _controllerName.text);

      logger.d("User document updated successfully");

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss the loading indicator
        // Navigate to the genre selection page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GenreSelectionPage()),
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
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.grey)
                            : null,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Icon(Icons.add, color: Colors.white),
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
                const SizedBox(height: 35),
                CustomSubmitButton(
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
}
