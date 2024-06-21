import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class InscriptionProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase;
  final prefs = SharedPrefsHelper();

  InscriptionProvider(FirebaseFirestore? firestore)
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

  //Retorna una lista de usuarios inscriptos a un gimnasio
  Future<List<UsuarioBasico>> usuariosInscriptos(String gymId) async {
    List<UsuarioBasico> users = [];
    try {
      //Get the ids of subscriced users
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

      //Fetch  each user document from the user collection using the ids

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
      //Get the ids of subscriced users
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

      //Fetch  each user document from the user collection using the ids

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
    // Fetch all users
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
    // Fetch pending users
    QuerySnapshot pendingSnapshot = await _firebase
        .collection(collection)
        .doc(gymId)
        .collection('pendiente')
        .get();
    Set<dynamic> pendingUserIds =
        pendingSnapshot.docs.map((doc) => doc['userId']).toSet();

    // Fetch subscribed users
    QuerySnapshot subscribedSnapshot = await _firebase
        .collection(collection)
        .doc(gymId)
        .collection('inscripto')
        .get();
    Set<dynamic> subscribedUserIds =
        subscribedSnapshot.docs.map((doc) => doc['userId']).toSet();

    // Filter out users who are in pending or subscribed lists
    List<UsuarioBasico> unsubscribedUsers = allUsers.where((user) {
      return !pendingUserIds.contains(user.docId) &&
          !subscribedUserIds.contains(user.docId);
    }).toList();

    return unsubscribedUsers;
  }

  Future<bool> formPending(String ownerId, String basicUserId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
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

  //funcionalidad de agregar una form request a la double
  Future<void> addFormRequest(String ownerId, String basicUserId) async {
    await _firebase.collection('form').add({
      'ownerId': ownerId,
      'basicUserId': basicUserId,
      'formData': {},
    });

    await _firebase
        .collection('usuario')
        .doc(basicUserId)
        .update({'asociadoId': ownerId});
    notifyListeners();
  }

  /*
  //funcionlidad de agarrar un form request para el owner
    Stream<List<GymForm>> getFormsForOwner(String ownerId) {
    return _firebase.collection('form')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GymForm.fromFirestore(doc))
        .toList());
  }*/

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

  Future<void> submitFormData(
      String formId, Map<String, dynamic> formData) async {
    await _firebase
        .collection('form')
        .doc(formId)
        .update({'formData': formData,'readOnly':true});
    notifyListeners();
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
      await FirebaseFirestore.instance.collection('evaluation').add({
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
      // Get the document from the "pendiente" subcollection
      QuerySnapshot pendingSnapshot = await _firebase
          .collection(collection)
          .doc(gymId)
          .collection('pendiente')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (pendingSnapshot.docs.isNotEmpty) {
        DocumentSnapshot pendingDoc = pendingSnapshot.docs.first;

        // Copy the document data to the "subscripto" subcollection
        await _firebase
            .collection(collection)
            .doc(gymId)
            .collection('inscripto')
            .doc(pendingDoc.id)
            .set(pendingDoc.data() as Map<String, dynamic>);

        // Delete the original document from the "pendiente" subcollection
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
}
