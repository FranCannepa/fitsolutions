import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DietaProvider dietaProvider;
  late MockSharedPrefsHelper mockPrefs;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    when(mockPrefs.getUserId()).thenAnswer((_) async => 'user1');
    dietaProvider = DietaProvider(fakeFirestore, mockPrefs);
  });

  group('DietaProvider', () {
    test('getDieta returns a Dieta', () async {
      // Prepare data
      const userId = 'user1';
      const dietaId = 'dieta1';
      when(mockPrefs.getUserId()).thenAnswer((_) async => userId);

      await fakeFirestore.collection('usuario').doc(userId).set({
        'dietaId': dietaId,
      });

      await fakeFirestore.collection('dieta').doc(dietaId).set({
        'nombreDieta': 'Dieta 1',
        'topeCalorias': '2000',
      });

      final dieta = await dietaProvider.getDieta();

      expect(dieta, isNotNull);
      expect(dieta!.nombre, 'Dieta 1');
    });

    test('getDietas returns a list of Dietas', () async {
      // Prepare data
      const origenMembresia = 'subs1';
      when(mockPrefs.getSubscripcion())
          .thenAnswer((_) async => origenMembresia);

      await fakeFirestore.collection('dieta').add({
        'origenDieta': origenMembresia,
        'nombreDieta': 'Dieta 1',
        'topeCalorias': '2000',
      });

      final dietas = await dietaProvider.getDietas();

      expect(dietas, isNotEmpty);
      expect(dietas.first.nombre, 'Dieta 1');
    });

    test('agregarDieta adds a new Dieta', () async {
      final dietaData = {
        'nombreDieta': 'New Dieta',
        'topeCalorias': '1500',
      };

      final result = await dietaProvider.agregarDieta(dietaData);

      expect(result, isTrue);
      final snapshot = await fakeFirestore.collection('dieta').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first['nombreDieta'], 'New Dieta');
    });

    test('actualizarDieta updates an existing Dieta', () async {
      // Prepare data
      const dietaId = 'dieta1';
      await fakeFirestore.collection('dieta').doc(dietaId).set({
        'nombreDieta': 'Old Dieta',
        'topeCalorias': '2000',
      });

      final dietaData = {
        'nombreDieta': 'Updated Dieta',
        'topeCalorias': '1800',
      };

      final result = await dietaProvider.actualizarDieta(dietaData, dietaId);

      expect(result, isTrue);
      final snapshot =
          await fakeFirestore.collection('dieta').doc(dietaId).get();
      expect(snapshot['nombreDieta'], 'Updated Dieta');
    });

    test('asignarDieta assigns a Dieta to a user and sends a notification',
        () async {
      // Prepare data
      const dietaId = 'dieta1';
      const clienteId = 'user1';
      await fakeFirestore.collection('usuario').doc(clienteId).set({
        'fcmToken': 'mockToken',
      });

      final result = await dietaProvider.asignarDieta(dietaId, clienteId);

      expect(result, isTrue);
      final snapshot =
          await fakeFirestore.collection('usuario').doc(clienteId).get();
      expect(snapshot['dietaId'], dietaId);
    });

    test('eliminarDieta deletes a Dieta and updates user documents', () async {
      // Prepare data
      const dietaId = 'dieta1';
      await fakeFirestore.collection('dieta').doc(dietaId).set({
        'nombreDieta': 'Dieta to delete',
      });

      await fakeFirestore.collection('usuario').add({
        'dietaId': dietaId,
      });

      final result = await dietaProvider.eliminarDieta(dietaId);

      expect(result, isTrue);
      final dietaSnapshot =
          await fakeFirestore.collection('dieta').doc(dietaId).get();
      expect(dietaSnapshot.exists, isFalse);

      final userSnapshot = await fakeFirestore
          .collection('usuario')
          .where('dietaId', isEqualTo: dietaId)
          .get();
      expect(userSnapshot.docs, isEmpty);
    });
  });
}
