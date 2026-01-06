import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService().history;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.notifications, color: Colors.blue),
                  ),
                  title: Text(n['title'] ?? 'Notification'),
                  subtitle: Text(n['body'] ?? ''),
                  trailing: Text(
                    (n['timestamp'] ?? '').toString().split('T').join(' '),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}
