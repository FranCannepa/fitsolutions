import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class InscriptionProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase;
  final SharedPrefsHelper prefs;
  final NotificationService _notificationService;

  InscriptionProvider(FirebaseFirestore? firestore, this._notificationService, this.prefs)
      : _firebase = firestore ?? FirebaseFirestore.instance {
    _firebase.collection('gimnasio').snapshots().listen((snapshot) {
      notifyListeners();
    });
    _firebase.collection('trainerInfo').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }

  Future<String?> gymLoggedIn() async {
    String? userId = await prefs.getUserId();

    if (userId == null) {
      return null;
    }

    final esEntrenador = await prefs.esEntrenador();
    String? collection = 'gimnasio';
    if (esEntrenador) {
      collection = 'trainerInfo';
    }

    QuerySnapshot trainerSnapshot = await _firebase
        .collection(collection)
        .where('propietarioId', isEqualTo: userId)
        .get();

    if (trainerSnapshot.docs.isNotEmpty) {
      return trainerSnapshot.docs.first.id;
    }

    return null;
  }


  Future<List<UsuarioBasico>> usuariosInscriptos(String gymId) async {
    List<UsuarioBasico> users = [];
    try {

      final esEntrenador = await prefs.esEntrenador();
      String? collection = 'gimnasio';
      if (esEntrenador) {
        collection = 'trainerInfo';
      }
      QuerySnapshot? inscriptos = await _firebase
          .collection(collection)
          .doc(gymId)
          .collection('inscripto')
          .get();



      for (var doc in inscriptos.docs) {
        String userId = doc['userId'];
        DocumentSnapshot userDoc =
            await _firebase.collection('usuario').doc(userId).get();
        if (userDoc.exists) {
          UsuarioBasico user = UsuarioBasico.fromDocument(
              userDoc.id, userDoc.data() as Map<String, dynamic>);
          users.add(user);
        }
      }
    } catch (e) {
      log.e(e);
    }
    return users;
  }

  Future<List<UsuarioBasico>> usuariosPendientes(String gymId) async {
    List<UsuarioBasico> users = [];
    try {

      final esEntrenador = await prefs.esEntrenador();
      String? collection = 'gimnasio';
      if (esEntrenador) {
        collection = 'trainerInfo';
      }
      QuerySnapshot? pendientes = await _firebase
          .collection(collection)
          .doc(gymId)
          .collection('pendiente')
          .get();



      for (var doc in pendientes.docs) {
        String userId = doc['userId'];
        DocumentSnapshot userDoc =
            await _firebase.collection('usuario').doc(userId).get();
        if (userDoc.exists) {
          UsuarioBasico user = UsuarioBasico.fromDocument(
              userDoc.id, userDoc.data() as Map<String, dynamic>);
          users.add(user);
        }
      }
    } catch (e) {
      log.e(e);
    }
    return users;
  }

  Future<void> addUserToPending(String gymId, String userId) async {
    try {
      final esEntrenador = await prefs.esEntrenador();
      String? collection = 'gimnasio';
      if (esEntrenador) {
        collection = 'trainerInfo';
      }
      await _firebase
          .collection(collection)
          .doc(gymId)
          .collection('pendiente')
          .add({'userId': userId});
      notifyListeners();
    } catch (e) {
      log.d("Error adding user to pending: $e");
    }
  }

  Future<List<UsuarioBasico>> getUnsubscribedUsers(String gymId) async {

    QuerySnapshot allUsersSnapshot = await _firebase
        .collection('usuario')
        .where('tipo', isEqualTo: 'Basico')
        .get();
    List<UsuarioBasico> allUsers = allUsersSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return !data.containsKey('asociadoId');
    }).map((doc) {
      return UsuarioBasico.fromDocument(
          doc.id, doc.data() as Map<String, dynamic>);
    }).toList();

    final esEntrenador = await prefs.esEntrenador();
    String? collection = 'gimnasio';
    if (esEntrenador) {
      collection = 'trainerInfo';
    }

    QuerySnapshot pendingSnapshot = await _firebase
        .collection(collection)
        .doc(gymId)
        .collection('pendiente')
        .get();
    Set<dynamic> pendingUserIds =
        pendingSnapshot.docs.map((doc) => doc['userId']).toSet();


    QuerySnapshot subscribedSnapshot = await _firebase
        .collection(collection)
        .doc(gymId)
        .collection('inscripto')
        .get();
    Set<dynamic> subscribedUserIds =
        subscribedSnapshot.docs.map((doc) => doc['userId']).toSet();


    List<UsuarioBasico> unsubscribedUsers = allUsers.where((user) {
      return !pendingUserIds.contains(user.docId) &&
          !subscribedUserIds.contains(user.docId);
    }).toList();

    return unsubscribedUsers;
  }

  Future<bool> formPending(String ownerId, String basicUserId) async {
    try {
      var querySnapshot = await _firebase
          .collection('form')
          .where('ownerId', isEqualTo: ownerId)
          .where('basicUserId', isEqualTo: basicUserId)
          .limit(1)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      log.e(e);
      return false; // Return false in case of an error
    }
  }


  Future<void> addFormRequest(String ownerId, String basicUserId) async {
    try {
      await _firebase.collection('form').add({
        'ownerId': ownerId,
        'basicUserId': basicUserId,
        'formData': {},
      });

      await _firebase
          .collection('usuario')
          .doc(basicUserId)
          .update({'asociadoId': ownerId});

      final user = await _firebase.collection('usuario').doc(basicUserId).get();
      final token = user.data();
      _notificationService.sendNotification(
          token!['fcmToken'],
          'Formulario Disponible',
          'Tiene un formulario de Inscripcion disponible');
      notifyListeners();

      NotificationProvider(_firebase,SharedPrefsHelper()).addNotification(
          basicUserId,
          'Formulario Disponible',
          'Tiene un formulario de Inscripcion disponible',
          '/form_inscription');
    } catch (e) {
      rethrow;
    }
  }

  Future<FormModel?> getFormByUserId(String userId) async {
    QuerySnapshot formSnapshot = await _firebase
        .collection('form')
        .where('basicUserId', isEqualTo: userId)
        .get();
    if (formSnapshot.docs.isNotEmpty) {
      var doc = formSnapshot.docs.first;
      return FormModel.fromDocument(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<DocumentSnapshot> fetchGymOrTrainerInfo(String ownerId) async {

    final gymDoc = await _firebase.collection('gimnasio').doc(ownerId).get();


    if (gymDoc.exists) {
      return gymDoc;
    }


    final trainerDoc =
        await _firebase.collection('trainerInfo').doc(ownerId).get();


    return trainerDoc;
  }

  Future<void> submitFormData(
      String formId, Map<String, dynamic> formData) async {
    try {
      final form = await _firebase.collection('form').doc(formId).get();

      await _firebase
          .collection('form')
          .doc(formId)
          .update({'formData': formData, 'readOnly': true});


      final user = await _firebase
          .collection('usuario')
          .doc(form.get('basicUserId'))
          .get();
      final gym = await fetchGymOrTrainerInfo(form.get('ownerId'));
      final owner = await _firebase
          .collection('usuario')
          .doc(gym.get('propietarioId'))
          .get();

      final userToken = owner.get('fcmToken');

      _notificationService.sendNotification(userToken, 'Formulario Completado',
          'El usuario ${user.get('nombreCompleto')} completo el formulario');
      NotificationProvider(_firebase,SharedPrefsHelper()).addNotification(
          owner.id,
          'Formulario Completado',
          'El usuario ${user.get('nombreCompleto')} completo el formulario',
          '/inscription');

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<FormModel?> getFormData(String ownerId, String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firebase
          .collection('form')
          .where('ownerId', isEqualTo: ownerId)
          .where('basicUserId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        log.d(doc.data());
        return FormModel.fromDocument(
            doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      log.d(e);
    }
    return null;
  }

  Future<void> submitEvaluationForm({
    required String gymId,
    required String userId,
    required EvaluationModel evaluationModel,
  }) async {
    try {
      await _firebase.collection('evaluation').add({
        'gymId': gymId,
        'userId': userId,
        'sentadillaPie': evaluationModel.sentadillaPie,
        'sentadillaTobillos': evaluationModel.sentadillaTobillos,
        'sentadillaRodilla': evaluationModel.sentadillaRodilla,
        'sentadillaCadera': evaluationModel.sentadillaCadera,
        'sentadillaTronco': evaluationModel.sentadillaTronco,
        'sentadillaHombro': evaluationModel.sentadillaHombro,
        'tocarPuntasPieDerecho': evaluationModel.tocarPuntasPieDerecho,
        'tocarPuntasPieIzquierdo': evaluationModel.tocarPuntasPieIzquierdo,
        'dorsiflexionTobilloDerecho':
            evaluationModel.dorsiflexionTobilloDerecho,
        'dorsiflexionTobilloIzquierdo':
            evaluationModel.dorsiflexionTobilloIzquierdo,
        'eaprDerecho': evaluationModel.eaprDerecho,
        'eaprIzquierdo': evaluationModel.eaprIzquierdo,
        'hombroDerecho': evaluationModel.hombroDerecho,
        'hombroIzquierdo': evaluationModel.hombroIzquierdo,
        'pmrDerecho': evaluationModel.pmrDerecho,
        'pmrIzquierdo': evaluationModel.pmrIzquierdo,
        'planchaFrontal': evaluationModel.planchaFrontal,
        'lagartija': evaluationModel.lagartija,
        'sentadillaExcentrica': evaluationModel.sentadillaExcentrica,
      });

      final user = await _firebase.collection('usuario').doc(userId).get();
      _notificationService.sendNotification(
          user.get('fcmToken'),
          'Inscripcion Completada',
          'Se finalizo tu inscripcion!');
      NotificationProvider(_firebase,SharedPrefsHelper()).addNotification(
          user.id,
          'Inscripcion Completada',
          'Se finalizo tu inscripcion!',
          '/perfil');
    } catch (e) {
      log.e(e);
    }
  }

  Future<void> moveDocumentToSubscribed(String gymId, String userId) async {
    try {
      final esEntrenador = await prefs.esEntrenador();
      String? collection = 'gimnasio';
      if (esEntrenador) {
        collection = 'trainerInfo';
      }

      QuerySnapshot pendingSnapshot = await _firebase
          .collection(collection)
          .doc(gymId)
          .collection('pendiente')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (pendingSnapshot.docs.isNotEmpty) {
        DocumentSnapshot pendingDoc = pendingSnapshot.docs.first;


        await _firebase
            .collection(collection)
            .doc(gymId)
            .collection('inscripto')
            .doc(pendingDoc.id)
            .set(pendingDoc.data() as Map<String, dynamic>);


        await _firebase
            .collection(collection)
            .doc(gymId)
            .collection('pendiente')
            .doc(pendingDoc.id)
            .delete();

        notifyListeners();
      } else {
        log.e('No pending document found for userId: $userId');
      }
    } catch (e) {
      log.d('Error moving document: $e');
    }
  }

  Future<EvaluationModel?> getEvaluationData(
      String gymId, String userId) async {
    try {
      QuerySnapshot snapshot = await _firebase
          .collection('evaluation')
          .where('userId', isEqualTo: userId)
          .where('gymId', isEqualTo: gymId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return EvaluationModel.fromDocument(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      log.e('Error fetching evaluation data: $e');
      return null;
    }
  }

  Future<void> allowModification(String userId, String gymId) async {
    try {
      var querySnapshot = await _firebase
          .collection('form')
          .where('ownerId', isEqualTo: gymId)
          .where('basicUserId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('form')
            .doc(docId)
            .update({'readOnly': false});

        final user = await _firebase.collection('usuario').doc(userId).get();
        _notificationService.sendNotification(
            user.get('fcmToken'),
            'Modificacion de Inscripcion',
            'Se ha habilitado un formulario');
        NotificationProvider(_firebase,SharedPrefsHelper()).addNotification(
            user.id,
            'Modificacion de Inscripcion',
            'Se ha habilitado un formulario',
            '/perfil');
      } else {
        log.w('No matching document found');
      }
    } catch (e) {
      log.e('Error: $e');
    }
  }

  
}
