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
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/widget_tree.dart'; // Add this line

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
  bool isProcessingAuth = false;
  final Logger logger = Logger();

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> signInWithEmailAndPassword() async {
    if (isProcessingAuth) return; // Prevent multiple simultaneous attempts

    setState(() {
      isProcessingAuth = true;
      errorMessage = '';
    });

    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final fcm = Provider.of<FCMService>(context, listen: false);
    final messaging = Provider.of<FirebaseMessaging>(context, listen: false);

    if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
      setState(() {
        isProcessingAuth = false;
        errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (!isEmailValid(_controllerEmail.text.trim())) {
      setState(() {
        isProcessingAuth = false;
        errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    late BuildContext dialogContext;
    //show loading circle
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await CustomAuth(firebaseAuth: auth).signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);

      String? token = await messaging.getToken();
      if (token != null) {
        await fcm.storeFCMToken(token);
        await fcm.storeFCMTokenToFirestore(token);
      }

      fcm.setupTokenRefreshListener();

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WidgetTree()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop(); // Dismiss loading dialog
        setState(() {
          errorMessage = e.toString();
          isProcessingAuth = false;
        });
      }
      logger.e('Error signing in: $e');
    }
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
  }

  Widget _buildTitle(bool isTablet) {
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
        Text('Watchee',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white
                      : Theme.of(context).primaryColor,
                  fontSize: isTablet ? 45 : 35,
                )),
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

  Future<void> _handleGoogleSignIn() async {
    if (isProcessingAuth) return;
    setState(() {
      isProcessingAuth = true;
    });
    BuildContext dialogContext = context;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      final customGoogleAuth =
          Provider.of<CustomGoogleAuth>(context, listen: false);
      final result = await customGoogleAuth.signInWithGoogle();

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (result != null) {
        // Force a rebuild of the widget tree
        if (mounted) {
          setState(() {
            isProcessingAuth = false;
          });
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WidgetTree()),
              (route) => false,
            );
          }
        }
      } else if (context.mounted) {
        setState(() {
          isProcessingAuth = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to sign in with Google. Please try again.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isProcessingAuth = false;
      });
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildLoginContent(ColorScheme colorScheme, bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyTextField(
            controller: _controllerEmail, title: 'Email', obscureText: false),
        const SizedBox(height: 25),
        MyTextField(
            controller: _controllerPassword,
            title: 'Password',
            obscureText: true),
        const SizedBox(height: 10),
        _buildForgotPassword(),
        const SizedBox(height: 25),
        _errorMessage(),
        const SizedBox(height: 20),
        CustomSubmitButton(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            text: 'Sign In',
            onPressed: signInWithEmailAndPassword),
        const SizedBox(height: 35),
        _buildDivider(),
        const SizedBox(height: 20),
        _buildGoogleSignIn(),
        const SizedBox(height: 35),
        _buildRegisterButton(),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          RichText(
            text: TextSpan(
              text: 'Forgot password?',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              recognizer: TapGestureRecognizer()..onTap = _forgotPassword,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 0.5)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('Or continue with', style: TextStyle(fontSize: 18)),
          ),
          Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildGoogleSignIn() {
    return Container(
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
        onTap: () => _handleGoogleSignIn(),
        child: Image.asset(
          'lib/assets/google.png',
          fit: BoxFit.cover,
          height: 50,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return TextButton(
        onPressed: navigateToRegisterPage,
        child: const Text(
          'Not a member? Register now',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 500;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: (isTablet && isLandscape)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side with title
                      Expanded(
                          flex: 2,
                          child: Center(
                              child: _buildTitle(isTablet && isLandscape))),
                      // Right side with login content
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: _buildLoginContent(colorScheme, isDarkMode),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(isTablet && isLandscape),
                      const SizedBox(height: 50),
                      _buildLoginContent(colorScheme, isDarkMode),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
