import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSharedPrefsHelper mockPrefs;
  late GimnasioProvider gimnasioProvider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    gimnasioProvider = GimnasioProvider(fakeFirestore, mockPrefs);
  });
  test('getGym returns Gym object if data exists', () async {
    // Setup initial gym data
    final gymData = {
      'propietarioId': 'userId1',
      'nombreGimnasio': 'Test Gym',
      'direccion': '123 Test Street',
      'contacto': '123-456-7890',
      'logoUrl': 'http://example.com/logo.png',
      'horario': {
        'Lunes-Viernes': {
          'open': '6:00 AM',
          'close': '22:00 PM',
        },
        'Sabado': {
          'open': '8:00 AM',
          'close': '18:00 PM',
        },
        'Domingo': {
          'open': '10:00 AM',
          'close': '14:00 PM',
        },
      }
    };

    await fakeFirestore.collection('gimnasio').add(gymData);

    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getUserId()).thenAnswer((_) async => 'userId1');
    when(mockPrefs.esEntrenador()).thenAnswer((_) async => false);

    // Call the method
    final result = await gimnasioProvider.getGym();

    // Verify the results
    expect(result, isNotNull);
    expect(result!.nombreGimnasio, 'Test Gym');
    expect(result.direccion, '123 Test Street');
    expect(result.contacto, '123-456-7890');
    expect(result.logoUrl, 'http://example.com/logo.png');
    expect(result.horario['Lunes-Viernes']!['open'], '6:00 AM');
    expect(result.horario['Lunes-Viernes']!['close'], '22:00 PM');
    expect(result.horario['Sabado']!['open'], '8:00 AM');
    expect(result.horario['Sabado']!['close'], '18:00 PM');
    expect(result.horario['Domingo']!['open'], '10:00 AM');
    expect(result.horario['Domingo']!['close'], '14:00 PM');
  });

  test('getGym returns null if no data exists', () async {
    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getUserId()).thenAnswer((_) async => 'userId1');
    when(mockPrefs.esEntrenador()).thenAnswer((_) async => false);

    // Call the method
    final result = await gimnasioProvider.getGym();

    // Verify the results
    expect(result, isNull);
  });

  test(
      'getGym returns Gym object from trainerInfo collection if esEntrenador is true',
      () async {
    // Setup initial gym data
    final gymData = {
      'propietarioId': 'userId1',
      'nombreGimnasio': 'Test Gym',
      'direccion': '123 Test Street',
      'contacto': '123-456-7890',
      'logoUrl': 'http://example.com/logo.png',
      'horario': {
        'Lunes-Viernes': {
          'open': '6:00 AM',
          'close': '22:00 PM',
        },
        'Sabado': {
          'open': '8:00 AM',
          'close': '18:00 PM',
        },
        'Domingo': {
          'open': '10:00 AM',
          'close': '14:00 PM',
        },
      }
    };

    await fakeFirestore.collection('trainerInfo').add(gymData);

    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getUserId()).thenAnswer((_) async => 'userId1');
    when(mockPrefs.esEntrenador()).thenAnswer((_) async => true);

    // Call the method
    final result = await gimnasioProvider.getGym();

    // Verify the results
    expect(result, isNotNull);
    expect(result!.nombreGimnasio, 'Test Gym');
    expect(result.direccion, '123 Test Street');
    expect(result.contacto, '123-456-7890');
    expect(result.logoUrl, 'http://example.com/logo.png');
    expect(result.horario['Lunes-Viernes']!['open'], '6:00 AM');
    expect(result.horario['Lunes-Viernes']!['close'], '22:00 PM');
    expect(result.horario['Sabado']!['open'], '8:00 AM');
    expect(result.horario['Sabado']!['close'], '18:00 PM');
    expect(result.horario['Domingo']!['open'], '10:00 AM');
    expect(result.horario['Domingo']!['close'], '14:00 PM');
  });
  test('getInfoSubscripto returns Gym object from gimnasio collection',
      () async {
    // Setup initial gym data in gimnasio collection
    final gymData = {
      'nombreGimnasio': 'Test Gym',
      'direccion': '123 Test Street',
      'contacto': '123-456-7890',
      'logoUrl': 'http://example.com/logo.png',
      'horario': {
        'Lunes-Viernes': {
          'open': '6:00 AM',
          'close': '22:00 PM',
        },
        'Sabado': {
          'open': '8:00 AM',
          'close': '18:00 PM',
        },
        'Domingo': {
          'open': '10:00 AM',
          'close': '14:00 PM',
        },
      }
    };

    await fakeFirestore.collection('gimnasio').doc('userId1').set(gymData);

    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'userId1');

    // Call the method
    final result = await gimnasioProvider.getInfoSubscripto();

    // Verify the results
    expect(result, isNotNull);
    expect(result!.nombreGimnasio, 'Test Gym');
    expect(result.direccion, '123 Test Street');
    expect(result.contacto, '123-456-7890');
    expect(result.logoUrl, 'http://example.com/logo.png');
    expect(result.horario['Lunes-Viernes']!['open'], '6:00 AM');
    expect(result.horario['Lunes-Viernes']!['close'], '22:00 PM');
    expect(result.horario['Sabado']!['open'], '8:00 AM');
    expect(result.horario['Sabado']!['close'], '18:00 PM');
    expect(result.horario['Domingo']!['open'], '10:00 AM');
    expect(result.horario['Domingo']!['close'], '14:00 PM');
  });

  test('getInfoSubscripto returns Gym object from trainerInfo collection',
      () async {
    // Setup initial trainer data in trainerInfo collection
    final trainerData = {
      'nombreGimnasio': 'Trainer Gym',
      'direccion': '456 Trainer Street',
      'contacto': '987-654-3210',
      'logoUrl': 'http://example.com/logo.png',
      'horario': {
        'Lunes-Viernes': {
          'open': '5:00 AM',
          'close': '21:00 PM',
        },
        'Sabado': {
          'open': '7:00 AM',
          'close': '17:00 PM',
        },
        'Domingo': {
          'open': '9:00 AM',
          'close': '13:00 PM',
        },
      }
    };

    await fakeFirestore
        .collection('trainerInfo')
        .doc('userId1')
        .set(trainerData);

    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'userId1');

    // Call the method
    final result = await gimnasioProvider.getInfoSubscripto();

    // Verify the results
    expect(result, isNotNull);
    expect(result!.nombreGimnasio, 'Trainer Gym');
    expect(result.direccion, '456 Trainer Street');
    expect(result.contacto, '987-654-3210');
    expect(result.logoUrl, 'http://example.com/logo.png');
    expect(result.horario['Lunes-Viernes']!['open'], '5:00 AM');
    expect(result.horario['Lunes-Viernes']!['close'], '21:00 PM');
    expect(result.horario['Sabado']!['open'], '7:00 AM');
    expect(result.horario['Sabado']!['close'], '17:00 PM');
    expect(result.horario['Domingo']!['open'], '9:00 AM');
    expect(result.horario['Domingo']!['close'], '13:00 PM');
  });

  test('getInfoSubscripto returns null if no data exists', () async {
    // Stub the methods of SharedPrefsHelper
    when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'userId1');

    // Call the method
    final result = await gimnasioProvider.getInfoSubscripto();

    // Verify the results
    expect(result, isNull);
  });
  test('registerGym adds gym data to Firestore', () async {
    when(mockPrefs.getUserId()).thenAnswer((_) async => 'userId1');
    when(mockPrefs.esEntrenador()).thenAnswer((_) async => false);

    const name = 'Test Gym';
    const address = '123 Test Street';
    const contact = '123-456-7890';
    final openHours = {
      'Lunes - Viernes': const TimeOfDay(hour: 6, minute: 0),
      'Sabado': const TimeOfDay(hour: 8, minute: 0),
      'Domingo': const TimeOfDay(hour: 10, minute: 0),
    };
    final closeHours = {
      'Lunes - Viernes': const TimeOfDay(hour: 22, minute: 0),
      'Sabado': const TimeOfDay(hour: 18, minute: 0),
      'Domingo': const TimeOfDay(hour: 14, minute: 0),
    };

    await gimnasioProvider.registerGym(
      name,
      address,
      contact,
      openHours,
      closeHours,
    );

    final querySnapshot = await fakeFirestore
        .collection('gimnasio')
        .where('propietarioId', isEqualTo: 'userId1')
        .get();

    expect(querySnapshot.docs.length, 1);
    final gymData = querySnapshot.docs.first.data();
    expect(gymData['nombreGimnasio'], name);
    expect(gymData['direccion'], address);
    expect(gymData['contacto'], contact);
    expect(gymData['horario']['Lunes-Viernes']['open'], '6:00 AM');
    expect(gymData['horario']['Lunes-Viernes']['close'], '22:00 PM');
    expect(gymData['horario']['Sabado']['open'], '8:00 AM');
    expect(gymData['horario']['Sabado']['close'], '18:00 PM');
    expect(gymData['horario']['Domingo']['open'], '10:00 AM');
    expect(gymData['horario']['Domingo']['close'], '14:00 PM');
  });

  test('updateGym updates gym data in Firestore', () async {
    // Set up initial gym data
    when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'gymId1');
    when(mockPrefs.esEntrenador()).thenAnswer((_) async => false);

    final initialGymData = {
      'nombreGimnasio': 'Initial Gym',
      'direccion': 'Initial Address',
      'contacto': '111-111-1111',
      'logoUrl': 'initialLogoUrl',
      'horario': {
        'Lunes-Viernes': {
          'open': '06:00 AM',
          'close': '10:00 PM',
        },
        'Sabado': {
          'open': '08:00 AM',
          'close': '06:00 PM',
        },
        'Domingo': {
          'open': '10:00 AM',
          'close': '02:00 PM',
        },
      }
    };

    await fakeFirestore
        .collection('gimnasio')
        .doc('gymId1')
        .set(initialGymData);

    // Update gym data
    const name = 'Updated Gym';
    const address = '123 Updated Street';
    const contact = '123-456-7890';
    const logo = 'updatedLogoUrl';
    final openHours = {
      'Lunes-Viernes': const TimeOfDay(hour: 6, minute: 0),
      'Sabado': const TimeOfDay(hour: 8, minute: 0),
      'Domingo': const TimeOfDay(hour: 10, minute: 0),
    };
    final closeHours = {
      'Lunes-Viernes': const TimeOfDay(hour: 22, minute: 0),
      'Sabado': const TimeOfDay(hour: 18, minute: 0),
      'Domingo': const TimeOfDay(hour: 14, minute: 0),
    };

    await gimnasioProvider.updateGym(
      name,
      address,
      contact,
      logo,
      openHours,
      closeHours,
    );

    // Verify the update
    final docSnapshot =
        await fakeFirestore.collection('gimnasio').doc('gymId1').get();
    final gymData = docSnapshot.data()!;

    expect(gymData['nombreGimnasio'], name);
    expect(gymData['direccion'], address);
    expect(gymData['contacto'], contact);
    expect(gymData['logoUrl'], logo);
    expect(gymData['horario']['Lunes-Viernes']['open'], '6:00 AM');
    expect(gymData['horario']['Lunes-Viernes']['close'], '22:00 PM');
    expect(gymData['horario']['Sabado']['open'], '8:00 AM');
    expect(gymData['horario']['Sabado']['close'], '18:00 PM');
    expect(gymData['horario']['Domingo']['open'], '10:00 AM');
    expect(gymData['horario']['Domingo']['close'], '14:00 PM');
  });
  test('getClientesGym returns list of clients for given gymId', () async {
    // Setup initial client data
    const gymId = 'gymId1';
    final userData1 = {
      'asociadoId': gymId,
      'tipo': 'Basico',
      'nombreCompleto': 'User One'
    };
    final userData2 = {
      'asociadoId': gymId,
      'tipo': 'Basico',
      'nombreCompleto': 'User Two'
    };

    await fakeFirestore.collection('usuario').add(userData1);
    await fakeFirestore.collection('usuario').add(userData2);

    // Call the method
    final result = await gimnasioProvider.getClientesGym(gymId);

    // Verify the results
    expect(result.length, 2);
    expect(result[0]['nombreCompleto'], 'User One');
    expect(result[1]['nombreCompleto'], 'User Two');
    expect(result[0]['usuarioId'], isNotNull);
    expect(result[1]['usuarioId'], isNotNull);
  });

  test('getClientesGym returns empty list if no clients found', () async {
    // Setup with no clients
    const gymId = 'gymId1';

    // Call the method
    final result = await gimnasioProvider.getClientesGym(gymId);

    // Verify the results
    expect(result, isEmpty);
  });

  test(
      'getParticipantesActividad returns list of participants for given activityId',
      () async {
    // Setup initial participant data
    const activityId = 'activityId1';
    final participantData1 = {
      'actividadId': activityId,
      'participanteId': 'userId1'
    };
    final participantData2 = {
      'actividadId': activityId,
      'participanteId': 'userId2'
    };
    final userData1 = {'nombreCompleto': 'User One'};
    final userData2 = {'nombreCompleto': 'User Two'};

    await fakeFirestore
        .collection('actividadParticipante')
        .add(participantData1);
    await fakeFirestore
        .collection('actividadParticipante')
        .add(participantData2);
    await fakeFirestore.collection('usuario').doc('userId1').set(userData1);
    await fakeFirestore.collection('usuario').doc('userId2').set(userData2);

    // Call the method
    final result = await gimnasioProvider.getParticipantesActividad(activityId);

    // Verify the results
    expect(result.length, 2);
    expect(result[0]['nombreCompleto'], 'User One');
    expect(result[1]['nombreCompleto'], 'User Two');
  });

  test('getParticipantesActividad returns empty list if no participants found',
      () async {
    // Setup with no participants
    const activityId = 'activityId1';

    // Call the method
    final result = await gimnasioProvider.getParticipantesActividad(activityId);

    // Verify the results
    expect(result, isEmpty);
  });
}
