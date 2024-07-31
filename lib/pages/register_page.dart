import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dima_project/pages/auth.dart';
import 'package:dima_project/widgets/my_textfield.dart';
//import 'package:dima_project/services/error_handler.dart';
import 'package:dima_project/pages/welcome_page.dart'; // Adjust the import path as needed
import 'package:dima_project/widgets/custom_submit_button.dart';

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

  Future<bool> isEmailAlreadyInUse(String email) async {
    final result =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return result.isNotEmpty;
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

    if (await isEmailAlreadyInUse(_controllerEmail.text.trim())) {
      setState(() {
        errorMessage = 'This email is already in use.';
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create user account
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );

      if (userCredential.user != null) {
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss the loading dialog
          // Navigate to the WelcomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      } else {
        throw Exception('Failed to create user.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }

    if (mounted) Navigator.of(context).pop();
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
