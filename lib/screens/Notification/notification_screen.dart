import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;

  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the back arrow color here
          ),
          backgroundColor: Colors.black,
          title: const Text(
            'Notificationes',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          )),
      body: StreamBuilder<List<NotificationModel>>(
        stream: provider.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: NoDataError(message: 'NO HAY NOTIFICACIONES'));
          }

          var notifications = snapshot.data!;

          // Group notifications by date
          var groupedNotifications = <String, List<NotificationModel>>{};
          for (var notification in notifications) {
            var date = DateFormat('yyyy-MM-dd')
                .format(notification.timestamp.toLocal());
            if (groupedNotifications[date] == null) {
              groupedNotifications[date] = [];
            }
            groupedNotifications[date]!.add(notification);
          }

          return ListView.builder(
            itemCount: groupedNotifications.length,
            itemBuilder: (context, index) {
              var date = groupedNotifications.keys.elementAt(index);
              var dateNotifications = groupedNotifications[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  // Notifications
                  ...dateNotifications.map((notification) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                        trailing: notification.read
                            ? null
                            : const Icon(Icons.circle,
                                color: Colors.red, size: 12),
                        onTap: () async {
                          provider.markAsRead(userId, notification.id);
                          Navigator.pushNamed(context, notification.route);
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
