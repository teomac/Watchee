import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage = '';
  String? successMessage = '';

  Future<void> resetPassword() async {
    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _controllerEmail.text.trim(),
      );
      setState(() {
        successMessage = 'Password reset email sent. Check your inbox.';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
    if (mounted) {
      Navigator.of(context).pop();
    } // Dismiss the loading dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please enter the email associated with your account.',
                  style: TextStyle(fontSize: 18),
                  //make the text red
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _controllerEmail,
                  title: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                CustomSubmitButton(
                  text: 'Reset Password',
                  onPressed: resetPassword,
                ),
                const SizedBox(height: 20),
                if (errorMessage != '')
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (successMessage != '')
                  Text(
                    successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ));
  }
}
