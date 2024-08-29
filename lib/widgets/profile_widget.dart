import 'package:flutter/material.dart';
import 'package:dima_project/models/user_model.dart';

class ProfileMenu extends StatelessWidget {
  final MyUser user;
  final VoidCallback onManageAccountTap;
  final VoidCallback onAppSettingsTap;
  final VoidCallback onSignOutTap;

  const ProfileMenu({
    super.key,
    required this.user,
    required this.onManageAccountTap,
    required this.onAppSettingsTap,
    required this.onSignOutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
        const Divider(),
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
