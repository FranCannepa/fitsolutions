import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:fitsolutions/modelo/models.dart';

class NotificationProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase;
  final prefs = SharedPrefsHelper();

  NotificationProvider(
    FirebaseFirestore? firestore,
  ) : _firebase = firestore ?? FirebaseFirestore.instance;
  Future<void> addNotification(
      String userId, String title, String message, String route) async {
    final notification = NotificationModel(
      id: '',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      read: false,
      route: route,
    );

    await _firebase
        .collection('usuario')
        .doc(userId)
        .collection('notification')
        .add(notification.toMap());
  }

  Stream<List<NotificationModel>> getUserNotifications(String? userId) {
    if (userId != null) {
      return _firebase
          .collection('usuario')
          .doc(userId)
          .collection('notification')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList());
    }
    return Stream.value([]);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await FirebaseFirestore.instance
        .collection('usuario')
        .doc(userId)
        .collection('notification')
        .doc(notificationId)
        .update({'read': true});
    notifyListeners();
  }
}
