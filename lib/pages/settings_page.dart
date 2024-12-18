import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';
import 'package:dima_project/services/fcm_settings_service.dart';
import 'package:logger/logger.dart';
import 'package:dima_project/pages/tos.dart';
import 'package:dima_project/pages/privacy_policy.dart ';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
      ),
      body: ListView(
        children: [
          _buildSection('General', [
            const ThemeSelectorWidget(),
          ]),
          _buildSection('Notification Preferences', [
            _buildPushNotificationToggle(),
          ]),
          _buildSection('About', [
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('Version'),
              subtitle: Text('1.0.0'), // Replace with your app's version
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServicePage(),
                  ),
                ); // Navigate to Terms of Service
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage()),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildPushNotificationToggle() {
    final FCMSettingsService fcm = Provider.of<FCMSettingsService>(context);
    return FutureBuilder<bool>(
      future: fcm.isPushNotificationsEnabled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Push Notifications'),
            trailing: CircularProgressIndicator(),
          );
        }

        bool pushNotificationsEnabled = snapshot.data ?? false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SwitchListTile(
              title: const Text('Push Notifications'),
              value: pushNotificationsEnabled,
              onChanged: (bool value) async {
                setState(() {
                  pushNotificationsEnabled = value;
                });

                try {
                  await fcm.setPushNotificationsEnabled(value);
                  _showSuccessSnackBar(value
                      ? 'Push notifications enabled'
                      : 'Push notifications disabled');
                } catch (e) {
                  _logger.e('Error toggling push notifications: $e');
                  setState(() {
                    pushNotificationsEnabled = !value;
                  });
                  _showErrorSnackBar('Failed to update notification settings');
                }
              },
            );
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          title: const Text('Theme'),
          trailing: DropdownButton<ThemeMode>(
            value: themeProvider.themeMode,
            onChanged: (ThemeMode? newThemeMode) {
              if (newThemeMode != null) {
                themeProvider.setThemeMode(newThemeMode);
              }
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System default'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        );
      },
    );
  }
}
