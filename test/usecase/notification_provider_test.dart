import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsolutions/providers/notification_provider.dart';


import 'actividad_provider_test.mocks.dart';


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSharedPrefsHelper mockPrefs;
  late NotificationProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    provider = NotificationProvider(fakeFirestore, mockPrefs);
  });

  group('NotificationProvider Tests', () {
    test('addNotification adds a new notification', () async {
      await provider.addNotification('user1', 'Test Title', 'Test Message', '/testRoute');

      final snapshot = await fakeFirestore.collection('usuario').doc('user1').collection('notification').get();
      expect(snapshot.docs.length, 1);
      final notification = snapshot.docs.first.data();
      expect(notification['title'], 'Test Title');
      expect(notification['message'], 'Test Message');
      expect(notification['route'], '/testRoute');
    });

    test('getUserNotifications returns user notifications', () async {
      await fakeFirestore.collection('usuario').doc('user1').collection('notification').add({
        'title': 'Test Title',
        'message': 'Test Message',
        'timestamp': DateTime.now(),
        'read': false,
        'route': '/testRoute',
      });

      final stream = provider.getUserNotifications('user1');
      final notifications = await stream.first;
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Test Title');
    });

    test('markAsRead marks the notification as read', () async {
      final notificationRef = await fakeFirestore.collection('usuario').doc('user1').collection('notification').add({
        'title': 'Test Title',
        'message': 'Test Message',
        'timestamp': DateTime.now(),
        'read': false,
        'route': '/testRoute',
      });

      await provider.markAsRead('user1', notificationRef.id);

      final updatedDoc = await fakeFirestore.collection('usuario').doc('user1').collection('notification').doc(notificationRef.id).get();
      expect(updatedDoc.data()!['read'], true);
    });
  });
}
