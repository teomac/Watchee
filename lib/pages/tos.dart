import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  // The actual terms of service text
  static const String _termsText = '''
# Terms of Service

Last Updated: October 28, 2024

## 1. Introduction

Welcome to Watchee. These Terms of Service ("Terms") govern your access to and use of the Watchee mobile application ("App"), operated by Watchee ("we," "us," or "our"). By using our App, you agree to be bound by these Terms.

## 2. Data Sources and Attribution

### 2.1 TMDB Attribution
This product uses the TMDB API but is not endorsed or certified by TMDB. All movie-related data and images are provided by The Movie Database (TMDB). We are grateful for their services and maintain compliance with their terms of use.

### 2.2 JustWatch Attribution
Streaming availability information is provided courtesy of JustWatch. We acknowledge their service in providing accurate and up-to-date streaming provider data.

## 3. User Accounts

### 3.1 Account Creation
You must create an account to use certain features of our App. You agree to provide accurate, current, and complete information during registration and to update such information to keep it accurate, current, and complete.

### 3.2 Account Security
You are responsible for safeguarding your account credentials and for any activities or actions under your account. You must immediately notify us of any unauthorized use of your account.

## 4. User Content

### 4.1 Content Ownership
You retain ownership of any content you create, share, or upload to the App ("User Content"). By posting User Content, you grant us a non-exclusive, royalty-free license to use, display, and distribute your User Content.

### 4.2 Content Guidelines
You agree not to post content that:
- Is illegal, defamatory, or fraudulent
- Infringes on intellectual property rights
- Contains hate speech or promotes discrimination
- Contains spam or malicious code
- Harasses or bullies others

## 5. Privacy

### 5.1 Data Collection
We collect and process personal data as described in our Privacy Policy. By using our App, you consent to such processing and warrant that all data provided by you is accurate.

### 5.2 Data Security
We implement reasonable security measures to protect your personal information but cannot guarantee absolute security.

## 6. Intellectual Property

### 6.1 App Content
The App and its original content (excluding User Content and third-party content) are and will remain the exclusive property of Watchee and its licensors.

### 6.2 Third-Party Content
Movie data, images, and related content are owned by their respective rights holders and are protected by applicable copyright and intellectual property laws.

## 7. Prohibited Activities

You agree not to:
- Use the App for any illegal purpose
- Attempt to gain unauthorized access to any portion of the App
- Interfere with or disrupt the App's functionality
- Create multiple accounts or share account credentials
- Scrape or collect data from the App without permission

## 8. Termination

### 8.1 Account Termination
We reserve the right to suspend or terminate your account at our sole discretion, without notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties, or for any other reason.

### 8.2 Effect of Termination
Upon termination, your right to use the App will immediately cease. All provisions of these Terms which by their nature should survive termination shall survive.

## 9. Disclaimers

### 9.1 Service "AS IS"
The App is provided on an "AS IS" and "AS AVAILABLE" basis. We make no warranties, expressed or implied, regarding the operation of the App or the information, content, or materials included.

### 9.2 Accuracy of Information
While we strive to provide accurate information, we cannot guarantee the accuracy, completeness, or timeliness of movie data, streaming availability, or other content.

## 10. Limitation of Liability

To the fullest extent permitted by law, Watchee shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the App.

## 11. Changes to Terms

We reserve the right to modify these Terms at any time. We will notify users of any material changes via the App or email. Your continued use of the App following such modifications constitutes your acceptance of the updated Terms.

## 12. Contact Information

If you have any questions about these Terms, please contact us at matteo.laini@mail.polimi.it or matteo.macaluso@mail.polimi.it.

## 13. Governing Law

These Terms shall be governed by and construed in accordance with the laws of Italy, without regard to its conflict of law provisions.

By using Watchee, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.
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
        title: const Text('Terms of Service'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Markdown(
          data: _termsText,
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
