import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:dima_project/pages/welcome_page.dart';
import 'package:dima_project/models/user_model.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  String? errorMessage = '';

  bool isPasswordValid(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<String> getUniqueUsername(String baseUsername) async {
    String username =
        baseUsername.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    int suffix = 1;
    bool isUnique = false;

    try {
      while (!isUnique) {
        // Query the 'users' collection for documents where 'username' matches the current username
        QuerySnapshot usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1) // Limit to 1 result for efficiency
            .get();

        if (usernameQuery.docs.isEmpty) {
          // If no documents are found, the username is unique
          isUnique = true;
          return username;
        } else {
          // If the username exists, append a number and try again
          username = '$baseUsername$suffix';
          suffix++;
        }
      }
    } catch (e) {
      print("Error querying Firestore for usernames: $e");
      // Fallback: use a timestamp to ensure uniqueness
      username = '${baseUsername}_${DateTime.now().millisecondsSinceEpoch}';
      print("Warning: Unable to verify username uniqueness. Using $username");
    }

    return username;
  }

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (!isEmailValid(_controllerEmail.text.trim())) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    if (!isPasswordValid(_controllerPassword.text)) {
      setState(() {
        errorMessage =
            'Password must be at least 8 characters long, contain 1 uppercase letter, 1 number, and 1 special character.';
      });
      return;
    }

    // Clear any previous error messages
    setState(() {
      errorMessage = '';
    });

    try {
      // Show loading dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Generate base username from email
      String baseUsername = _controllerEmail.text
          .trim()
          .split('@')[0]
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '');
      String uniqueUsername = await getUniqueUsername(baseUsername);

      // Create user account
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );

      if (userCredential.user != null) {
        // Create MyUser object
        MyUser newUser = MyUser(
          id: userCredential.user!.uid,
          username: uniqueUsername,
          name: '',
          email: _controllerEmail.text.trim(),
          birthdate: DateTime.now(),
          favoriteGenres: [],
          friendList: [],
          likedMovies: [],
          customLists: {},
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        // Navigate to the WelcomeScreen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        throw Exception('Failed to create user.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = e.message ?? 'An error occurred during registration.';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      // Ensure the loading dialog is dismissed
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _errorMessage() {
    if (errorMessage == '') {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyTextField(
                  controller: _controllerEmail,
                  title: 'Email',
                  obscureText: false),
              const SizedBox(height: 25),
              MyTextField(
                  controller: _controllerPassword,
                  title: 'Password',
                  obscureText: true),
              const SizedBox(height: 25),
              MyTextField(
                  controller: _controllerConfirmPassword,
                  title: 'Confirm password',
                  obscureText: true),
              const SizedBox(height: 25),
              _errorMessage(),
              const SizedBox(height: 20),
              CustomSubmitButton(
                text: 'Register',
                onPressed: createUserWithEmailAndPassword,
              ),
              const SizedBox(height: 35),
              TextButton(
                  onPressed: widget.showLoginPage,
                  child: const Text('Already have an account? Login now',
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        )));
  }
}
