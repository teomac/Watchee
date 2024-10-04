import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/pages/account/user_profile_page.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:dima_project/services/watchlist_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  final MyUser user;

  const NotificationsPage({super.key, required this.user});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final UserService _userService = UserService();
  final WatchlistService _watchlistService = WatchlistService();

  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _userService.getNotifications(widget.user.id);
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _notificationsFuture = _userService.getNotifications(widget.user.id);
    });
  }

  Future<void> _confirmClearAll() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Notifications'),
          content:
              const Text('Are you sure you want to clear all notifications?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _userService.clearNotifications(widget.user.id);
      setState(() {
        _notificationsFuture = _userService.getNotifications(widget.user.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) async {
              if (value == 'clear') {
                await _confirmClearAll();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear all notifications'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          } else {
            List<Map<String, dynamic>> notifications = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final DateTime timestamp =
                      (notification['timestamp'] as Timestamp).toDate();
                  final formattedTimestamp = timeago.format(timestamp);
                  final String userId = notification['type'] == 'new_review'
                      ? notification['reviewAuthorId']
                      : notification['type'] == 'new_follower'
                          ? notification['followerId']
                          : notification['watchlistOwner'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Dismissible(
                      key: Key(notification['notificationId'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await _userService.removeNotification(
                            widget.user.id, notification['notificationId']);

                        setState(() {
                          notifications.removeAt(index);
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification dismissed'),
                            ),
                          );
                        }
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading:
                                  _getNotificationIcon(notification['type']),
                              title: Text(
                                notification['message'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                formattedTimestamp,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: notification['type'] != 'new_invitation'
                                  ? () async {
                                      MyUser? user =
                                          await _userService.getUser(userId);
                                      if (user != null && context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfilePage(user: user),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                            if (notification['type'] == 'new_invitation')
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _acceptInvitation(
                                          widget.user.id,
                                          notification), // Unclickable for now
                                      child: const Text('Accept'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _declineInvitation(
                                          widget.user.id,
                                          notification), // Unclickable for now
                                      child: const Text('Decline'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'new_follower':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'new_review':
        return const Icon(Icons.comment, color: Colors.green);
      case 'movie_release':
        return const Icon(Icons.movie, color: Colors.red);
      case 'new_invitation':
        return const Icon(Icons.playlist_add, color: Colors.orange);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  Future<void> _acceptInvitation(
      String userId, Map<String, dynamic> notification) async {
    await _watchlistService.acceptInvite(
        notification['watchlistId'], notification['watchlistOwner'], userId);
    //remove notification
    await _userService.removeNotification(
        userId, notification['notificationId']);
    setState(() {
      _notificationsFuture = _userService.getNotifications(widget.user.id);
    });
  }

  Future<void> _declineInvitation(
      String userId, Map<String, dynamic> notification) async {
    await _watchlistService.declineInvite(
        notification['watchlistId'], notification['watchlistOwner'], userId);
    //remove notification
    await _userService.removeNotification(
        userId, notification['notificationId']);
    setState(() {
      _notificationsFuture = _userService.getNotifications(widget.user.id);
    });
  }
}
