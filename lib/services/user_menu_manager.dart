import 'package:dima_project/pages/account/notifications_page.dart';
import 'package:dima_project/pages/account/user_profile_page.dart';
import 'package:dima_project/pages/login_and_register/login_page.dart';
import 'package:dima_project/services/custom_auth.dart';
import 'package:dima_project/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/pages/account/manage_account.dart';
import 'package:dima_project/pages/settings_page.dart';
import 'package:dima_project/widgets/profile_widget.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatefulWidget {
  final VoidCallback? onFavoriteGenresUpdated;
  final UserService? userService;
  final CustomAuth? auth;
  final NotificationsService? notificationsService;

  const UserInfo(
      {super.key,
      this.onFavoriteGenresUpdated,
      this.userService,
      this.auth,
      this.notificationsService});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  MyUser? _currentUser;
  final Logger logger = Logger();
  late UserService _userService;
  late CustomAuth _auth;
  late NotificationsService _notificationsService;

  @override
  void initState() {
    super.initState();
    _userService =
        widget.userService ?? Provider.of<UserService>(context, listen: false);
    _auth = widget.auth ?? Provider.of<CustomAuth>(context, listen: false);
    _notificationsService = widget.notificationsService ??
        Provider.of<NotificationsService>(context, listen: false);
    _initializeData();
    _initFCM();
  }

  Future<void> _initFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (mounted) {
        setState(() {
          _notificationsService.incrementUnreadCount();
        });
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      final user = await _userService.getCurrentUser();

      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      logger.d('Error initializing data: $e');
      // Handle error (e.g., show a snackbar or dialog)
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.75,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: ProfileMenu(
                user: _currentUser ??
                    MyUser(
                      id: '',
                      name: '',
                      username: '',
                      email: '',
                    ),
                onManageAccountTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageAccountPage(
                        onFavoriteGenresUpdated: widget.onFavoriteGenresUpdated,
                      ),
                    ),
                  ).then((_) {
                    _initializeData();
                  });
                },
                onAppSettingsTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
                onSignOutTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
                onUserTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(user: _currentUser!)));
                },
                onNotificationsTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                                user: _currentUser!,
                              ))).then((_) {
                    setState(() {
                      _notificationsService.resetUnreadCount();
                    });
                  });
                },
                unreadCount: _notificationsService.unreadCount,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      bool success = await _auth.signOut();
      if (success) {
        logger.d('Sign out successful');
        //remove anything from the stack and navigate to the login page
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        logger.e('Sign out failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to sign out. Please try again.')),
          );
        }
      }
    } catch (e) {
      logger.e('Error during sign out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<MyUser?>(
      future: _userService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          logger.d('Error loading user data: ${snapshot.error}');
          return Icon(
            Icons.error,
            color: isDarkMode ? Colors.white : Colors.black,
          );
        }
        final user = snapshot.data;
        return InkWell(
          onTap: () => _showProfileMenu(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                child: user?.profilePicture != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          user!.profilePicture!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            logger.d('Error loading profile picture: $error');
                            return Icon(
                              Icons.person,
                              size: 24,
                              color: isDarkMode ? Colors.white : Colors.black,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 24,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
              ),
              if (_notificationsService.unreadCount > 0)
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
                        '${_notificationsService.unreadCount}',
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
        );
      },
    );
  }
}
