import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fitsolutions/modelo/evaluation_model.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'actividad_provider_test.mocks.dart';

@GenerateMocks([NotificationService])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockSharedPrefsHelper prefs;
  late InscriptionProvider provider;
  late NotificationService notificationService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    prefs = MockSharedPrefsHelper();
    notificationService = NotificationService();
    provider = InscriptionProvider(firestore, notificationService, prefs);
  });

  group('InscriptionProvider Tests', () {
    test('gymLoggedIn returns correct gym ID', () async {
      // Set up fake data
      const gymId = 'gym1';
      await firestore.collection('gimnasio').doc(gymId).set({
        'propietarioId': 'user1',
      });
      when(prefs.getUserId()).thenAnswer((_) async => 'user1');
      when(prefs.esEntrenador()).thenAnswer((_) async => false);

      final result = await provider.gymLoggedIn();

      expect(result, gymId);
    });

    test('usuariosInscriptos returns correct list of users', () async {
      // Set up fake data
      const gymId = 'gym1';
      const userId = 'user1';
      when(prefs.esEntrenador()).thenAnswer((_) async => false);
      await firestore
          .collection('gimnasio')
          .doc(gymId)
          .collection('inscripto')
          .doc('inscripto1')
          .set({
        'userId': userId,
      });
      await firestore.collection('usuario').doc(userId).set({
        'nombreCompleto': 'John Doe',
        'email': 'johndoe@example.com',
      });

      final result = await provider.usuariosInscriptos(gymId);

      expect(result.length, 1);
      expect(result.first.docId, userId);
      expect(result.first.nombreCompleto, 'John Doe');
    });

    test('addUserToPending adds user to pending collection', () async {
      // Set up fake data
      const gymId = 'gym1';
      const userId = 'user1';
      when(prefs.esEntrenador()).thenAnswer((_) async => false);

      await provider.addUserToPending(gymId, userId);

      final snapshot = await firestore
          .collection('gimnasio')
          .doc(gymId)
          .collection('pendiente')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['userId'], userId);
    });

        test('usuariosPendientes returns correct list of pending users', () async {
      // Set up fake data
      const gymId = 'gym1';
      const userId = 'user1';
      await firestore.collection('gimnasio').doc(gymId).collection('pendiente').doc('pendiente1').set({
        'userId': userId,
      });
      await firestore.collection('usuario').doc(userId).set({
        'nombreCompleto': 'Jane Doe',
        'email': 'janedoe@example.com',
      });
      when(prefs.esEntrenador()).thenAnswer((_) async => false);

      final result = await provider.usuariosPendientes(gymId);

      expect(result.length, 1);
      expect(result.first.docId, userId);
      expect(result.first.nombreCompleto, 'Jane Doe');
    });

     test('getUnsubscribedUsers returns correct list of unsubscribed users', () async {
      // Set up fake data
      const gymId = 'gym1';
      const unsubscribedUserId = 'user1';
      const pendingUserId = 'user2';
      const subscribedUserId = 'user3';

      await firestore.collection('usuario').doc(unsubscribedUserId).set({
        'nombreCompleto': 'User One',
        'tipo': 'Basico',
      });

      await firestore.collection('usuario').doc(pendingUserId).set({
        'nombreCompleto': 'User Two',
        'tipo': 'Basico',
      });

      await firestore.collection('usuario').doc(subscribedUserId).set({
        'nombreCompleto': 'User Three',
        'tipo': 'Basico',
      });

      await firestore.collection('gimnasio').doc(gymId).collection('pendiente').doc('pendiente1').set({
        'userId': pendingUserId,
      });

      await firestore.collection('gimnasio').doc(gymId).collection('inscripto').doc('inscripto1').set({
        'userId': subscribedUserId,
      });

      when(prefs.esEntrenador()).thenAnswer((_) async => false);

      final result = await provider.getUnsubscribedUsers(gymId);

      expect(result.length, 1);
      expect(result.first.docId, unsubscribedUserId);
      expect(result.first.nombreCompleto, 'User One');
    });

     test('formPending returns true if no form exists', () async {
      const ownerId = 'owner1';
      const basicUserId = 'user1';

      final result = await provider.formPending(ownerId, basicUserId);

      expect(result, true);
    });

    test('formPending returns false if form exists', () async {
      const ownerId = 'owner1';
      const basicUserId = 'user1';

      await firestore.collection('form').add({
        'ownerId': ownerId,
        'basicUserId': basicUserId,
        'formData': {},
      });

      final result = await provider.formPending(ownerId, basicUserId);

      expect(result, false);
    });

    test('addFormRequest adds form request and updates user', () async {
      const ownerId = 'owner1';
      const basicUserId = 'user1';
      const fcmToken = 'fcmToken';

      await firestore.collection('usuario').doc(basicUserId).set({
        'fcmToken': fcmToken,
      });

      await provider.addFormRequest(ownerId, basicUserId);

      final formSnapshot = await firestore
          .collection('form')
          .where('ownerId', isEqualTo: ownerId)
          .where('basicUserId', isEqualTo: basicUserId)
          .get();

      final userSnapshot = await firestore.collection('usuario').doc(basicUserId).get();

      expect(formSnapshot.docs.length, 1);
      expect(userSnapshot.data()?['asociadoId'], ownerId);
    });

    test('getFormByUserId returns correct form model', () async {
      const formId = 'form1';
      const basicUserId = 'user1';
      final formData = {'someField': 'someValue'};

      await firestore.collection('form').doc(formId).set({
        'basicUserId': basicUserId,
        'formData': formData,
      });

      final result = await provider.getFormByUserId(basicUserId);

      expect(result, isNotNull);
      expect(result?.formId, formId);
    });

    test('getFormByUserId returns null if no form exists', () async {
      const basicUserId = 'user1';

      final result = await provider.getFormByUserId(basicUserId);

      expect(result, isNull);
    });

        test('submitEvaluationForm adds evaluation and sends notification', () async {
      const gymId = 'gym1';
      const userId = 'user1';
      final evaluationModel = EvaluationModel.fromDocument(
        {
        'sentadillaPie': '1',
        'sentadillaTobillos': '2',
        'sentadillaRodilla': '3',
        'sentadillaCadera': '4',
        'sentadillaTronco': '5',
        'sentadillaHombro': '6',
        'tocarPuntasPieDerecho': '7',
        'tocarPuntasPieIzquierdo': '8',
        'dorsiflexionTobilloDerecho': '9',
        'dorsiflexionTobilloIzquierdo': '10',
        'eaprDerecho': '11',
        'eaprIzquierdo': '12',
        'hombroDerecho': '13',
        'hombroIzquierdo': '14',
        'pmrDerecho': '15',
        'pmrIzquierdo': '16',
        'planchaFrontal': '17',
        'lagartija': '18',
        'sentadillaExcentrica': '19',
        }
      );
      const fcmToken = 'fcmToken';

      await firestore.collection('usuario').doc(userId).set({
        'fcmToken': fcmToken,
      });

      await provider.submitEvaluationForm(
        gymId: gymId,
        userId: userId,
        evaluationModel: evaluationModel,
      );

      final evaluationSnapshot = await firestore
          .collection('evaluation')
          .where('gymId', isEqualTo: gymId)
          .where('userId', isEqualTo: userId)
          .get();

      expect(evaluationSnapshot.docs.length, 1);
      expect(evaluationSnapshot.docs.first.data()['sentadillaPie'], evaluationModel.sentadillaPie);
    });

    test('moveDocumentToSubscribed moves document from pendiente to inscripto', () async {
      const gymId = 'gym1';
      const userId = 'user1';
      const docId = 'doc1';

      when(prefs.esEntrenador()).thenAnswer((_) async => false);

      await firestore.collection('gimnasio').doc(gymId).collection('pendiente').doc(docId).set({
        'userId': userId,
        'someField': 'someValue',
      });

      await provider.moveDocumentToSubscribed(gymId, userId);

      final pendingSnapshot = await firestore
          .collection('gimnasio')
          .doc(gymId)
          .collection('pendiente')
          .where('userId', isEqualTo: userId)
          .get();

      final subscribedSnapshot = await firestore
          .collection('gimnasio')
          .doc(gymId)
          .collection('inscripto')
          .where('userId', isEqualTo: userId)
          .get();

      expect(pendingSnapshot.docs.length, 0);
      expect(subscribedSnapshot.docs.length, 1);
      expect(subscribedSnapshot.docs.first.data()['someField'], 'someValue');
    });

    test('getEvaluationData returns correct evaluation model', () async {
      const gymId = 'gym1';
      const userId = 'user1';
      final evaluationData = {
        'gymId': gymId,
        'userId': userId,
        'sentadillaPie': '1',
        'sentadillaTobillos': '2',
        'sentadillaRodilla': '3',
        'sentadillaCadera': '4',
        'sentadillaTronco': '5',
        'sentadillaHombro': '6',
        'tocarPuntasPieDerecho': '7',
        'tocarPuntasPieIzquierdo': '8',
        'dorsiflexionTobilloDerecho': '9',
        'dorsiflexionTobilloIzquierdo': '10',
        'eaprDerecho': '11',
        'eaprIzquierdo': '12',
        'hombroDerecho': '13',
        'hombroIzquierdo': '14',
        'pmrDerecho': '15',
        'pmrIzquierdo': '16',
        'planchaFrontal': '17',
        'lagartija': '18',
        'sentadillaExcentrica': '19',
      };

      await firestore.collection('evaluation').add(evaluationData);

      final result = await provider.getEvaluationData(gymId, userId);

      expect(result, isNotNull);
      expect(result?.sentadillaPie, '1');
      expect(result?.sentadillaTobillos, '2');
      expect(result?.sentadillaRodilla, '3');
      expect(result?.sentadillaCadera, '4');
      expect(result?.sentadillaTronco, '5');
      expect(result?.sentadillaHombro, '6');
    });

    test('getEvaluationData returns null if no evaluation exists', () async {
      const gymId = 'gym1';
      const userId = 'user1';

      final result = await provider.getEvaluationData(gymId, userId);

      expect(result, isNull);
    });
  });
}
