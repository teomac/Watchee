import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _privacyText = '''
# Privacy Policy

Last Updated: October 28, 2024

## 1. Introduction

Welcome to Watchee ("we," "us," or "our"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.

## 2. Information We Collect

### 2.1 Information You Provide
We collect information that you voluntarily provide, including:
- Account information (email, username, name)
- Profile information (profile picture)
- User-generated content (reviews, ratings, watchlists)
- Communications with other users
- Genre preferences and movie interests

### 2.2 Automatically Collected Information
We automatically collect certain information when you use our App:
- Device information (device type, operating system)
- Log data and usage statistics
- Firebase authentication tokens
- Push notification tokens
- IP address and location data

### 2.3 Third-Party Services
We use third-party services that may collect information:
- Firebase Authentication for user management
- Firebase Cloud Firestore for data storage
- Firebase Cloud Messaging for notifications
- The Movie Database (TMDB) for movie information
- JustWatch for streaming service availability

## 3. How We Use Your Information

We use the collected information to:
- Create and manage your account
- Provide our core app features
- Send notifications about activity
- Improve our services
- Respond to your requests
- Prevent fraud and abuse
- Comply with legal obligations

## 4. Data Storage and Security

### 4.1 Data Storage
Your data is stored securely on Firebase servers located in the European Union, in compliance with GDPR requirements.

### 4.2 Security Measures
We implement appropriate technical and organizational security measures to protect your data, including:
- Secure HTTPS transmission
- Data encryption
- Access controls
- Regular security assessments

## 5. Data Sharing and Disclosure

### 5.1 Information We Share
We may share your information with:
- Other users (based on your privacy settings)
- Service providers and partners
- Legal authorities when required by law

### 5.2 Third-Party Services
Our app integrates with:
- Firebase services (Privacy Policy: https://firebase.google.com/support/privacy)
- TMDB API (Privacy Policy: https://www.themoviedb.org/privacy-policy)
- JustWatch (Privacy Policy: https://www.justwatch.com/us/privacy-policy)

## 6. Your Rights Under GDPR

As a user based in the European Union, you have the right to:
- Access your personal data
- Correct inaccurate data
- Request data deletion
- Object to data processing
- Data portability
- Withdraw consent
- File a complaint with supervisory authorities

## 7. Data Retention

We retain your data for as long as your account is active or as needed to provide services. You may request deletion of your account and associated data at any time.

## 8. Children's Privacy

Our App is not intended for children under 13. We do not knowingly collect information from children under 13 years of age.

## 9. International Data Transfers

Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place for such transfers in compliance with GDPR requirements.

## 10. Changes to This Policy

We may update this Privacy Policy periodically. We will notify you of any material changes via email or through the App.

## 11. Cookie Policy

Our app does not use cookies directly, but our third-party services may use similar technologies for authentication and security purposes.

## 12. Contact Information

For privacy-related inquiries or to exercise your rights, contact us at:
- Email: matteo.laini@mail.polimi.it or matteo.macaluso@mail.polimi.it

## 13. Legal Basis for Processing

Under GDPR, we process your data based on:
- Your consent
- Contract performance
- Legal obligations
- Legitimate interests

## 14. Supervisory Authority

You have the right to lodge a complaint with the Italian Data Protection Authority (Garante per la protezione dei dati personali):
- Website: https://www.garanteprivacy.it/
- Email: protocollo@gpdp.it

This privacy policy was last updated on October 28, 2024.
''';

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Markdown(
          data: _privacyText,
          styleSheet: MarkdownStyleSheet(
            h1: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            h2: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            h3: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
            p: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
            listBullet: TextStyle(
              color: colorScheme.primary,
            ),
            blockquoteDecoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            a: TextStyle(
              color: colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          onTapLink: (text, href, title) {
            if (href != null) {
              _launchURL(href);
            }
          },
        ),
      ),
    );
  }
}
