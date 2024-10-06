import 'dart:async';
import 'package:dima_project/services/auth.dart';
import 'package:dima_project/services/fcm_service.dart';
import 'package:dima_project/services/google_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:dima_project/pages/login_and_register/register_page.dart';
//import 'package:dima_project/services/error_handler.dart';
import 'package:dima_project/pages/login_and_register/reset_password_page.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
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
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        await FMCService.storeFCMToken(token);
        await FMCService.storeFCMTokenToFirestore(token);
      }

      FMCService.setupTokenRefreshListener();
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

  Widget _title() {
    return const Text(
      'Authentication logo here',
      style: TextStyle(
        color: Colors.black,
        fontSize: 32,
      ),
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: _title(),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: SafeArea(
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
                      text: 'Sign In', onPressed: signInWithEmailAndPassword),

                  const SizedBox(height: 35),

                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
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
                          onTap: () => AuthService().signInWithGoogle(),
                          child: Image.asset(
                            'lib/images/google.png',
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
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ))
                    ],
                  )
                ]),
          ),
        ));
  }
}
