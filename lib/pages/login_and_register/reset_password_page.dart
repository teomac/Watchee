import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dima_project/widgets/my_textfield.dart';
import 'package:dima_project/widgets/custom_submit_button.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  String? errorMessage = '';
  String? successMessage = '';

  void cleanErrorMessages() {
    setState(() {
      errorMessage = '';
      successMessage = '';
    });
  }

  Future<void> resetPassword() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);

    cleanErrorMessages();

    if (_controllerEmail.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email';
      });
      return;
    }
    //check if the email is valid
    if (!_controllerEmail.text.contains('@')) {
      setState(() {
        errorMessage = 'Please enter a valid email';
      });
      return;
    }

    BuildContext dialogContext = context;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await auth.sendPasswordResetEmail(
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
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext); // Dismiss the loading dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                  key: const Key('reset_password_button'),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
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
