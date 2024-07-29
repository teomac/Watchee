import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dima_project/pages/auth.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/services/error_handler.dart';

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
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerSurname = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  String? errorMessage = '';

  Future<void> createUserWithEmailAndPassword() async {
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (_controllerName.text.isEmpty ||
        _controllerSurname.text.isEmpty ||
        _controllerAge.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields';
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
        password: _controllerPassword.text.trim(),
      );

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _controllerName.text.trim(),
        'surname': _controllerSurname.text.trim(),
        'age': int.parse(_controllerAge.text.trim()),
        'email': _controllerEmail.text.trim(),
      });
      // Update the user's display name in Firebase Auth
      await userCredential.user!.updateDisplayName(
          '${_controllerName.text} ${_controllerSurname.text}');

      if (mounted) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        // You might want to navigate to a new page or show a success message here
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.app_registration, size: 100),
                const SizedBox(height: 30),
                MyTextField(
                  controller: _controllerEmail,
                  title: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _controllerPassword,
                  title: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _controllerConfirmPassword,
                  title: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _controllerName,
                  title: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _controllerSurname,
                  title: 'Surname',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  controller: _controllerAge,
                  title: 'Age',
                  obscureText: false,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: createUserWithEmailAndPassword,
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                if (errorMessage!.isNotEmpty)
                  Text(
                    ErrorHandler.getErrorMessage(errorMessage!),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.showLoginPage,
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
