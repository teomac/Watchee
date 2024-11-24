import 'dart:async';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/custom_google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:dima_project/pages/login_and_register/register_page.dart';
import 'package:dima_project/pages/login_and_register/reset_password_page.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> signInWithEmailAndPassword() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);

    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (!isEmailValid(_controllerEmail.text.trim())) {
      setState(() {
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    BuildContext dialogContext = context;
    //show loading circle
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      _cleanErrorMessage();
      await CustomAuth(firebaseAuth: auth).signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        await FCMService.storeFCMToken(token);
        await FCMService.storeFCMTokenToFirestore(token);
      }

      FCMService.setupTokenRefreshListener();
    } catch (e) {
      setState(() {
        // Set a more specific error message if possible
        errorMessage = e.toString();
      });
    } finally {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  void _cleanErrorMessage() {
    setState(() {
      errorMessage = '';
    });
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

  void navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RegisterPage(
                showLoginPage: () => Navigator.pop(context),
              )),
    );
  }

  Widget _errorMessage() {
    //if error message is empty, return an empty container
    if (errorMessage == '') {
      return const SizedBox();
    } else {
      // else, return the error message centered in the screen
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Text(
          //ErrorHandler.getErrorMessage(errorMessage!),
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 15),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      obscureText: true),

                  const SizedBox(height: 10),

                  // forgot password?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            text: 'Forgot password?',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 15),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _forgotPassword,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  _errorMessage(),
                  const SizedBox(height: 20),

                  CustomSubmitButton(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      text: 'Sign In',
                      onPressed: signInWithEmailAndPassword),

                  const SizedBox(height: 35),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            thickness: 0.5,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // google sign in button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 27, 27, 27)
                              : Colors.white,
                        ),
                        child: GestureDetector(
                          key: const Key('google_sign_in_button'),
                          onTap: () => Provider.of<CustomGoogleAuth>(context,
                                  listen: false)
                              .signInWithGoogle(),
                          child: Image.asset(
                            'lib/assets/google.png',
                            fit: BoxFit.cover,
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // not a member? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: navigateToRegisterPage,
                          child: const Text(
                            'Not a member? Register now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ))
                    ],
                  )
                ]),
          ),
        ))));
  }
}
