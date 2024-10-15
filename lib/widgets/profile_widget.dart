import 'package:flutter/material.dart';
import 'package:dima_project/models/user.dart';

class ProfileMenu extends StatelessWidget {
  final MyUser user;
  final VoidCallback onManageAccountTap;
  final VoidCallback onAppSettingsTap;
  final VoidCallback onSignOutTap;
  final VoidCallback onUserTap;
  final VoidCallback onNotificationsTap;
  final int unreadCount;

  const ProfileMenu({
    super.key,
    required this.user,
    required this.onManageAccountTap,
    required this.onAppSettingsTap,
    required this.onSignOutTap,
    required this.onUserTap,
    required this.onNotificationsTap,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: onUserTap,
            child: CircleAvatar(
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
        const Divider(),
        ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 16,
                      maxHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: const Text('Notifications'),
          onTap: onNotificationsTap,
        ),
        ListTile(
          leading: const Icon(Icons.manage_accounts),
          title: const Text('Manage Account'),
          onTap: onManageAccountTap,
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('App Settings'),
          onTap: onAppSettingsTap,
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Sign Out'),
          onTap: onSignOutTap,
        ),
      ],
    );
  }
}
