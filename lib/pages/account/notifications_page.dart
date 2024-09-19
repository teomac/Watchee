import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final DateTime timestamp =
                      (notification['timestamp'] as Timestamp).toDate();
                  final formattedTimestamp =
                      DateFormat('dd-MM-yyyy - kk:mm').format(timestamp);

                  return ListTile(
                    title: Text(notification['message']),
                    subtitle: Text(formattedTimestamp),
                  );
                },
              );
            }
          }),
    );
  }
}
