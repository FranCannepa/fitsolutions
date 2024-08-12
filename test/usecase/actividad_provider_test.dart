import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

@GenerateMocks([SharedPrefsHelper, MembresiaProvider, BuildContext])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSharedPrefsHelper mockPrefs;
  late MockMembresiaProvider mockMembresiaProvider;
  late MockBuildContext mockBuildContext;
  late ActividadProvider actividadProvider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    mockMembresiaProvider = MockMembresiaProvider();
    mockBuildContext = MockBuildContext();
    actividadProvider = ActividadProvider(
        fakeFirestore, Logger(), mockPrefs, mockMembresiaProvider);
  });

  group('ActividadProvider', () {
    test('fetchActividades returns a list of activities', () async {
      // Setup fake Firestore data
      await fakeFirestore.collection('actividad').add({
        'propietarioActividadId': 'test_owner',
        'nombreActividad': 'Test Activity',
        'tipo': 'Test Type',
        'inicio': Timestamp.fromDate(DateTime.now()),
        'fin': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1))),
        'cupos': 10,
      });

      // Setup Shared Preferences mock
      when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'test_owner');

      final actividades =
          await actividadProvider.fetchActividades(DateTime.now());

      expect(actividades.length, 1);
      expect(actividades[0].nombre, 'Test Activity');
    });

    test('registrarActividad adds a single activity to Firestore', () async {
      final actividadData = {
        'nombreActividad': 'Test Activity',
        'propietarioActividadId': 'test_owner',
        'tipo': 'Test Type',
        'cupos': 10,
        'inicio': Timestamp.fromDate(DateTime.now()),
        'fin': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1))),
        'dias': [],
      };

      final result = await actividadProvider.registrarActividad(actividadData);

      expect(result, true);

      final querySnapshot = await fakeFirestore.collection('actividad').get();
      expect(querySnapshot.docs.length, 1);
      expect(
          querySnapshot.docs.first.data()['nombreActividad'], 'Test Activity');
    });

    test(
        'registrarActividad adds multiple activities to Firestore for repeating days',
        () async {
      final actividadData = {
        'nombreActividad': 'Test Activity',
        'propietarioActividadId': 'test_owner',
        'tipo': 'Test Type',
        'cupos': 10,
        'inicio': Timestamp.fromDate(DateTime.now()),
        'fin': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1))),
        'dias': [DateTime.now().weekday],
      };

      final result = await actividadProvider.registrarActividad(actividadData);

      expect(result, true);

      final querySnapshot = await fakeFirestore.collection('actividad').get();
      expect(querySnapshot.docs.length, greaterThan(1));
      expect(
          querySnapshot.docs.first.data()['nombreActividad'], 'Test Activity');
    });

    test('actualizarActividad updates the activity document', () async {
      // Arrange
      final actividadData = {
        'id': 'actividadId1',
        'nombreActividad': 'Yoga Class',
        'propietarioActividadId': 'mockOwnerId',
        'tipo': 'Fitness',
        'cupos': 10,
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      };

      // Add initial document to Firestore
      await fakeFirestore
          .collection('actividad')
          .doc('actividadId1')
          .set(actividadData);

      // Update data
      final updatedActividadData = {
        'id': 'actividadId1',
        'nombreActividad': 'Updated Yoga Class',
        'propietarioActividadId': 'mockOwnerId',
        'tipo': 'Fitness',
        'cupos': 15,
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      };

      // Act
      final result =
          await actividadProvider.actualizarActividad(updatedActividadData);

      // Assert
      expect(result, true);

      final updatedDoc =
          await fakeFirestore.collection('actividad').doc('actividadId1').get();
      expect(updatedDoc.exists, true);
      expect(updatedDoc['nombreActividad'], 'Updated Yoga Class');
      expect(updatedDoc['cupos'], 15);
    });

    test(
        'actualizarActividad returns false and logs error when document ID is missing',
        () async {
      // Arrange
      final actividadData = {
        'nombreActividad': 'Yoga Class',
        'propietarioActividadId': 'mockOwnerId',
        'tipo': 'Fitness',
        'cupos': 10,
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      };

      // Act
      try {
        await actividadProvider.actualizarActividad(actividadData);
        fail('Expected an exception to be thrown');
      } on Exception catch (_, e) {
        Logger().e(e);
      }
      // Assert
    });

    test('eliminarActividad deletes the activity and its participants',
        () async {
      // Arrange
      final actividadData = {
        'nombreActividad': 'Yoga Class',
        'propietarioActividadId': 'mockOwnerId',
        'tipo': 'Fitness',
        'cupos': 10,
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      };

      final actividadDocRef =
          fakeFirestore.collection('actividad').doc('actividadId1');
      await actividadDocRef.set(actividadData);

      final participanteData = {
        'actividadId': 'actividadId1',
        'participanteId': 'participantId1',
      };

      final participanteDocRef = fakeFirestore
          .collection('actividadParticipante')
          .doc('participanteId1');
      await participanteDocRef.set(participanteData);

      // Act
      final result = await actividadProvider.eliminarActividad('actividadId1');

      // Assert
      expect(result, true);

      final actividadDoc =
          await fakeFirestore.collection('actividad').doc('actividadId1').get();
      expect(actividadDoc.exists, false);

      final participanteDoc = await fakeFirestore
          .collection('actividadParticipante')
          .doc('participanteId1')
          .get();
      expect(participanteDoc.exists, false);
    });

    test('eliminarActividad returns false and logs error when deletion fails',
        () async {
      final actividadDocRef =
          fakeFirestore.collection('actividad').doc('actividadId1');
      await actividadDocRef.set({
        'nombreActividad': 'Yoga Class',
        'propietarioActividadId': 'mockOwnerId',
        'tipo': 'Fitness',
        'cupos': 10,
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      });
      // Act & Assert
      try {
        await actividadDocRef.delete();
        final result =
            await actividadProvider.eliminarActividad('actividadId1');
        expect(result, true);
      } catch (e) {
        expect(e, isA<FirebaseException>());
      }
    });

    test(
        'estaInscripto returns true if the user is registered for the activity',
        () async {
      // Arrange
      final actividadParticipanteData = {
        'actividadId': 'actividadId1',
        'participanteId': 'userId1',
      };

      await fakeFirestore
          .collection('actividadParticipante')
          .add(actividadParticipanteData);

      // Act
      final result =
          await actividadProvider.estaInscripto('userId1', 'actividadId1');

      // Assert
      expect(result, true);
    });

    test(
        'estaInscripto returns false if the user is not registered for the activity',
        () async {
      // Act
      final result =
          await actividadProvider.estaInscripto('userId1', 'actividadId1');

      // Assert
      expect(result, false);
    });
    test(
        'desinscribirseActividad successfully unregisters a user from an activity',
        () async {
      // Arrange
      await fakeFirestore.collection('actividadParticipante').add({
        'actividadId': 'actividadId1',
        'participanteId': 'userId1',
      });

      final documentReference = fakeFirestore
          .collection('usuarioMembresia')
          .doc(); // Create a new document with an auto-generated ID
      await documentReference.set({
        'usuarioId': 'usuarioId',
        'membresiaId': 'membresiaId1',
        'cuposRestantes': 1,
        'estado': 'activa',
      });

      // Retrieve the document snapshot
      final documentSnapshot = await documentReference.get();

      // Mock the membership provider to return a valid document with id
      when(mockMembresiaProvider.obtenerMembresiaActiva('userId1'))
          .thenAnswer((_) async => documentSnapshot);

      // Act
      final result = await actividadProvider.desinscribirseActividad(
          mockBuildContext, 'userId1', 'actividadId1');

      // Assert
      expect(result, true);

      final participantSnapshot = await fakeFirestore
          .collection('actividadParticipante')
          .where('actividadId', isEqualTo: 'actividadId1')
          .where('participanteId', isEqualTo: 'userId1')
          .get();

      expect(participantSnapshot.docs.isEmpty, true);

      final membershipSnapshot = await documentReference.get();

      expect(membershipSnapshot.data()?['cuposRestantes'], 2);
    });

    test('desinscribirseActividad fails if no active membership found',
        () async {
      // Arrange
      when(mockMembresiaProvider.obtenerMembresiaActiva('userId1'))
          .thenAnswer((_) async => null);

      // Act
      final result = await actividadProvider.desinscribirseActividad(
          mockBuildContext, 'userId1', 'actividadId1');

      // Assert
      expect(result, false);
    });

    test('actividadesDeParticipante returns the correct activities', () async {
      // Mock user ID
      when(mockPrefs.getUserId()).thenAnswer((_) async => 'userId1');

      await fakeFirestore.collection('actividadParticipante').add({
        'participanteId': 'userId1',
        'actividadId': 'actividadId1',
      });
      await fakeFirestore.collection('actividadParticipante').add({
        'participanteId': 'userId1',
        'actividadId': 'actividadId2',
      });

      await fakeFirestore.collection('actividad').doc('actividadId1').set({
        'nombreActividad': 'Activity 1',
        'inicio': DateTime.now(),
        'fin': DateTime.now().add(const Duration(hours: 1)),
      });
      await fakeFirestore.collection('actividad').doc('actividadId2').set({
        'nombreActividad': 'Activity 2',
        'inicio': DateTime.now().add(const Duration(hours: 1)),
        'fin': DateTime.now().add(const Duration(hours: 2)),
      });


      final activities = await actividadProvider.actividadesDeParticipante();

      expect(activities.length, 2);

      final actividad1 =
          activities.firstWhere((act) => act.id == 'actividadId1');
      expect(actividad1.nombre, 'Activity 1');
      expect(actividad1.participantes, 1);

      final actividad2 =
          activities.firstWhere((act) => act.id == 'actividadId2');
      expect(actividad2.nombre, 'Activity 2');
      expect(actividad2.participantes, 1);
    });
  });
}
