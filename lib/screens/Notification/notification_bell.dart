import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/screens/Notification/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _notificationCount = 5; 
  final prefs = SharedPrefsHelper();
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  void getUserId() async{
    userId = await prefs.getUserId();
  }

  @override
  Widget build(BuildContext context) {

    return IconButton(
      icon: badges.Badge(
        badgeContent: Text(
          _notificationCount.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        showBadge: _notificationCount > 0,
        child:  const Icon(Icons.notifications),
      ),
      onPressed: () async{
        // Handle notification bell tap
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  NotificationScreen(userId: userId!)),
        );
        setState(() {
          _notificationCount = 0;
        });
      },
    );
  }
}