import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('NOTIFICACIONES')),
      body: StreamBuilder<List<NotificationModel>>(
        stream: provider.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('NO HAY NOTIFICACIONES'));
          }

          var notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              return ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: notification.read
                    ? null
                    : const Icon(Icons.circle, color: Colors.red, size: 12),
                onTap: () async {
                  provider.markAsRead(userId, notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}