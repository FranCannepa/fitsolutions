import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'actividad_provider_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockSharedPrefsHelper mockPrefs;
  late MembresiaProvider provider;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockPrefs = MockSharedPrefsHelper();
    provider = MembresiaProvider(fakeFirestore, mockPrefs);
  });

  group('MembresiaProvider Tests', () {
    test('getMembresiasOrigen returns list of Membresias', () async {
      await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'

      });

      when(mockPrefs.getSubscripcion()).thenAnswer((_) async => 'gym');

      final result = await provider.getMembresiasOrigen();

      expect(result.length, 1);
      expect(result[0].nombreMembresia, 'Gold');
    });

    test('registrarMembresia adds a new Membresia', () async {
      final newMembresia = {
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      };

      final result = await provider.registrarMembresia(newMembresia);

      expect(result, true);

      final snapshot = await fakeFirestore.collection('membresia').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['nombreMembresia'], 'Gold');
    });

    test('actualizarMembresia updates an existing Membresia', () async {
      final docRef = await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      });

      final updatedData = {
        'membresiaId': docRef.id,
        'nombreMembresia': 'Silver Updated',
      };

      final result = await provider.actualizarMembresia(updatedData);

      expect(result, true);

      final updatedDoc = await fakeFirestore.collection('membresia').doc(docRef.id).get();
      expect(updatedDoc.data()!['nombreMembresia'], 'Silver Updated');
    });

    test('eliminarMembresia deletes a Membresia', () async {
      final docRef = await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      });

      final result = await provider.eliminarMembresia(docRef.id);

      expect(result, true);

      final snapshot = await fakeFirestore.collection('membresia').get();
      expect(snapshot.docs.length, 0);
    });

    test('asignarMembresia assigns a new Membresia to a user', () async {
      final membresiaRef = await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      });

      final result = await provider.asignarMembresia(membresiaRef.id, 'user1');

      expect(result, true);

      final snapshot = await fakeFirestore.collection('usuarioMembresia').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['usuarioId'], 'user1');
      expect(snapshot.docs.first.data()['membresiaId'], membresiaRef.id);
    });

    test('obtenerMembresiaActiva returns active membership for user', () async {
      final membresiaRef = await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      });

      await fakeFirestore.collection('usuarioMembresia').add({
        'usuarioId': 'user2',
        'membresiaId': membresiaRef.id,
        'estado': 'activa',
        'fechaExpiracion': DateTime.now().add(const Duration(days: 30)),
        'cuposRestantes': 5,
      });

      final result = await provider.obtenerMembresiaActiva('user2');

      expect(result, isNotNull);
      //expect(result!.data()!['membresiaId'], membresiaRef.id);
    });

    test('cambiarEstadoMembresia updates the membership status', () async {
      final docRef = await fakeFirestore.collection('usuarioMembresia').add({
        'usuarioId': 'user2',
        'membresiaId': 'membresia1',
        'estado': 'activa',
      });

      await provider.cambiarEstadoMembresia(false, docRef.id);

      final updatedDoc = await fakeFirestore.collection('usuarioMembresia').doc(docRef.id).get();
      expect(updatedDoc.data()!['estado'], 'inactiva');
    });

    test('getNextMonth returns the correct next month date', () {
      final currentDate = DateTime(2023, 12, 31);
      final nextMonthDate = provider.getNextMonth(currentDate);

      expect(nextMonthDate.year, 2024);
      expect(nextMonthDate.month, 1);
      expect(nextMonthDate.day, 31);
    });

    test('asignarMembresia assigns a new membership', () async {
      final membresiaRef = await fakeFirestore.collection('membresia').add({
        'origenMembresia': 'gym',
        'nombreMembresia': 'Gold',
        'cupos': 10,
        'costo': '3000',
        'descripcion':'Desc de gold'
      });

      final result = await provider.asignarMembresia(membresiaRef.id, 'user3');

      expect(result, true);

      final snapshot = await fakeFirestore.collection('usuarioMembresia').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['usuarioId'], 'user3');
      expect(snapshot.docs.first.data()['membresiaId'], membresiaRef.id);
      expect(snapshot.docs.first.data()['estado'], 'activa');
    });

  });
}
