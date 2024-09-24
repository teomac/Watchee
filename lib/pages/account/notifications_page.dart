import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  final MyUser user;

  const NotificationsPage({super.key, required this.user});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final UserService _userService = UserService();
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _userService.getNotifications(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await _userService.clearNotifications(widget.user.id);
              setState(() {
                _notificationsFuture =
                    _userService.getNotifications(widget.user.id);
              });
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
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final DateTime timestamp =
                      (notification['timestamp'] as Timestamp).toDate();
                  final formattedTimestamp = timeago.format(timestamp);

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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification dismissed'),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: _getNotificationIcon(notification['type']),
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
                          onTap: () {},
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  Icon _getNotificationIcon(String type) {
    switch (type) {
      case 'new_follower':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'new_review':
        return const Icon(Icons.comment, color: Colors.green);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }
}
