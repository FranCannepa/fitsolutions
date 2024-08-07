import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsolutions/providers/chart_provider.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ChartProvider chartProvider;
  late MockSharedPrefsHelper mockPrefs;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    chartProvider = ChartProvider(fakeFirestore, mockPrefs);
    // Mock SharedPrefsHelper if needed
    // e.g., when(prefs.getSubscripcion()).thenAnswer((_) async => 'mockId');
  });

  group('ChartProvider', () {
    test('getAllActivities returns a list of activities', () async {
      // Prepare data
      const activityId = 'activity1';
      const userId = 'user1';

      await fakeFirestore.collection('actividad').doc(activityId).set({
        'propietarioActividadId': userId,
        'nombreActividad': 'Activity 1',
        'tipo': 'Type 1',
        'inicio': Timestamp.now(),
        'fin': Timestamp.now(),
        'cupos': 10,
        'participantes': 0
      });

      await fakeFirestore
          .collection('actividadParticipante')
          .add({'actividadId': activityId, 'participanteId': 'participant1'});

      when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'user1');

      final activities = await chartProvider.getAllActivities();

      expect(activities, isNotEmpty);
      expect(activities.first.nombre, 'Activity 1');
    });

    test('getAllActivitiesByDate returns activities within the date range',
        () async {
      // Prepare data
      const activityId = 'activity2';
      const userId = 'user2';

      final startOfMonth = DateTime.now();
      final endOfMonth = DateTime.now().add(const Duration(days: 30));

      await fakeFirestore.collection('actividad').doc(activityId).set({
        'propietarioActividadId': userId,
        'nombreActividad': 'Activity 2',
        'tipo': 'Type 2',
        'inicio': Timestamp.fromDate(startOfMonth),
        'fin': Timestamp.fromDate(endOfMonth),
        'cupos': 20,
        'participantes': 5
      });

      when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'user2');

      final activities = await chartProvider.getAllActivitiesByDate(
        month: startOfMonth.month,
        year: startOfMonth.year,
      );

      expect(activities, isNotEmpty);
      expect(activities.first.nombre, 'Activity 2');
    });

    test(
        'getParticipantsCount returns the number of participants for an activity',
        () async {
      // Prepare data
      const activityId = 'activity3';
      await fakeFirestore
          .collection('actividadParticipante')
          .add({'actividadId': activityId, 'participanteId': 'participant1'});
      await fakeFirestore
          .collection('actividadParticipante')
          .add({'actividadId': activityId, 'participanteId': 'participant2'});

      final count = await chartProvider.getParticipantsCount(activityId);

      expect(count, 2);
    });

    test('getAllParticipants returns a list of participants', () async {
      // Prepare data
      const userId = 'user3';
      const activityId = 'activity4';

      await fakeFirestore.collection('actividad').doc(activityId).set({
        'propietarioActividadId': userId,
        'nombreActividad': 'Activity 3',
        'tipo': 'Type 3',
        'inicio': Timestamp.now(),
        'fin': Timestamp.now(),
        'cupos': 15,
        'participantes': 10
      });

      await fakeFirestore
          .collection('actividadParticipante')
          .add({'actividadId': activityId, 'participanteId': 'participant2'});

      await fakeFirestore
          .collection('usuario')
          .doc('participant2')
          .set({'nombreCompleto': 'Participant 2', 'email': 'participant2@example.com'});

      when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'user3');

      final participants = await chartProvider.getAllParticipants();

      expect(participants, isNotEmpty);
      expect(participants.first.nombreCompleto, 'Participant 2');
    });
  });
}
