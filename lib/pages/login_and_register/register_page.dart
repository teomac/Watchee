import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:dima_project/pages/login_and_register/welcome_page.dart';
import 'package:dima_project/models/user.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/pages/tos.dart';
import 'package:dima_project/pages/privacy_policy.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({
    super.key,
    required this.showLoginPage,
  });

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  String? errorMessage = '';
  final Logger logger = Logger();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

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

  Future<void> createUserWithEmailAndPassword() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final firestore = Provider.of<FirebaseFirestore>(context, listen: false);

    if (_controllerEmail.text.isEmpty ||
        _controllerPassword.text.isEmpty ||
        _controllerConfirmPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      logger.w("Empty fields detected");
      return;
    }

    logger.d("Starting user registration process");
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      logger.w("Passwords do not match");
      return;
    }

    if (!isEmailValid(_controllerEmail.text.trim())) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      logger.w("Invalid email address");
      return;
    }

    if (!isPasswordValid(_controllerPassword.text)) {
      setState(() {
        errorMessage =
            'Password must be at least 8 characters long, contain 1 uppercase letter, 1 number, and 1 special character.';
      });
      logger.w("Invalid password");
      return;
    }

    setState(() {
      errorMessage = '';
    });

    try {
      logger.d("Showing loading dialog");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      logger.d("Generating unique username");
      logger.d("Creating user account with Firebase");
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );

      if (userCredential.user != null) {
        logger.d("User account created successfully");
        MyUser newUser = MyUser(
          id: userCredential.user!.uid,
          username: '',
          name: '',
          email: _controllerEmail.text.trim(),
          favoriteGenres: [],
          following: [],
          followers: [],
          likedMovies: [],
          seenMovies: [],
          followedWatchlists: {},
        );

        logger.d("Saving user data to Firestore");
        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());
        logger.d("User data saved to Firestore");

        FirebaseMessaging messaging = FirebaseMessaging.instance;
        String? token = await messaging.getToken();
        if (token != null) {
          await FCMService.storeFCMToken(token);
          await FCMService.storeFCMTokenToFirestore(token);
          logger.d("FCM token saved successfully");
        } else {
          logger.w("FCM token is null");
        }

        FCMService.setupTokenRefreshListener();
        logger.d("FCM token refresh listener set up");

        logger.d("Dismissing loading dialog");
        if (mounted) {
          Navigator.of(context).pop();
        }

        logger.d("Navigating to WelcomeScreen");

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        logger.e("Failed to create user account");
        if (mounted) {
          Navigator.of(context).pop();
        }
        throw Exception('Failed to create user.');
      }
    } on FirebaseAuthException catch (e) {
      logger.e("FirebaseAuthException: ${e.message}");
      if (mounted) {
        Navigator.of(context).pop();
      }
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = e.message ?? 'An error occurred during registration.';
        }
      });
    } catch (e) {
      logger.e("Unexpected error: $e");
      if (mounted) {
        Navigator.of(context).pop();
      }
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
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

  Widget _buildTitle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.movie,
          size: 40,
          color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 10),
        Text(
          'Watchee',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }

  void showTos() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TermsOfServicePage()));
  }

  void showPrivacyPolicy() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
              _buildTitle(),
              const SizedBox(height: 50),
              MyTextField(
                  controller: _controllerEmail,
                  title: 'Email',
                  obscureText: false),
              const SizedBox(height: 25),
              MyTextField(
                  controller: _controllerPassword,
                  title: 'Password',
                  obscureText: !isPasswordVisible,
                  fieldKey: const Key('password_field'),
                  showVisibilityToggle: true,
                  onVisibilityToggle: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  }),
              const SizedBox(height: 25),
              MyTextField(
                  controller: _controllerConfirmPassword,
                  title: 'Confirm password',
                  obscureText: !isConfirmPasswordVisible,
                  fieldKey: const Key('confirm_password_field'),
                  showVisibilityToggle: true,
                  onVisibilityToggle: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  }),
              const SizedBox(height: 25),
              _errorMessage(),
              const SizedBox(height: 20),
              CustomSubmitButton(
                key: const Key('register_button'),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                text: 'Register',
                onPressed: createUserWithEmailAndPassword,
              ),
              const SizedBox(height: 35),
              TextButton(
                  onPressed: widget.showLoginPage,
                  child: const Text('Already have an account? Login now',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 150),
              const Text('By registering, you agree to our:'),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                    onPressed: () => showTos(),
                    child: const Text('Terms of Service')),
                TextButton(
                    onPressed: () => showPrivacyPolicy(),
                    child: const Text('Privacy Policy')),
              ])
            ],
          ),
        )));
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
    super.dispose();
  }
}
