import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
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
            SwitchListTile(
              title: const Text('Push Notifications'),
              value:
                  true, // Replace with actual value from your state management
              onChanged: (value) {
                // Implement push notification toggle logic
              },
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value:
                  false, // Replace with actual value from your state management
              onChanged: (value) {
                // Implement email notification toggle logic
              },
            ),
          ]),
          _buildSection('About', [
            const ListTile(
              title: Text('Version'),
              subtitle: Text('1.0.0'), // Replace with your app's version
            ),
            ListTile(
              title: const Text('Terms of Service'),
              onTap: () {
                // Navigate to Terms of Service
              },
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              onTap: () {
                // Navigate to Privacy Policy
              },
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
