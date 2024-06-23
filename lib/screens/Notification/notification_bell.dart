import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:fitsolutions/screens/Notification/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class NotificationBell extends StatefulWidget {

  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
    final prefs = SharedPrefsHelper();
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() async{
    final result = await prefs.getUserId();
    setState(() {
      userId = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationProvider>();
    return StreamBuilder<List<NotificationModel>>(
      stream: provider.getUserNotifications(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          );
        }

        var unreadCount = snapshot.data!
            .where((notification) => !notification.read)
            .length;

        return IconButton(
          icon: badges.Badge(
            badgeContent: Text(
              unreadCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            showBadge: unreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(userId: userId!),
              ),
            );
          },
        );
      },
    );
  }
}