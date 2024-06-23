import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/notification_provider.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../modelo/models.dart';

class FitnessProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase; 
  final NotificationService _notificationService;

  FitnessProvider(FirebaseFirestore? firestore,this._notificationService) : _firebase = firestore ?? FirebaseFirestore.instance{
    _firebase.collection('plan').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }
  
  Future<void> sendNotification(String userId) async{
    final user = await _firebase.collection('usuario').doc(userId).get();
    final data = user.data();
    _notificationService.sendNotification(data!['fcmToken'],'Notification','Body');
  }

  Future<Plan?> getRutinaDeUsuario(String docId) async {
    CollectionReference collectionRef = _firebase.collection('usuario');
    DocumentReference documentRef = collectionRef.doc(docId);

    final dataUser = await documentRef.get();
    Map<String, dynamic> data = dataUser.data() as Map<String, dynamic>;
    Plan? plan = await getPlanById(data['rutina']);
    return plan;
  }

  //tested
  Future<Plan?> getPlanById(String planId) async {
    Logger log = Logger();
    try {
      // Retrieve the document with the specified planId
      DocumentSnapshot planDoc =
          await _firebase.collection('plan').doc(planId).get();

      // Check if the document exists
      if (planDoc.exists) {
        // Retrieve weeks for the plan
        QuerySnapshot weeksSnapshot = await _firebase
            .collection('plan')
            .doc(planId)
            .collection('week')
            .get();
        List<Week> weeks =
            await Future.wait(weeksSnapshot.docs.map((weekDoc) async {
          // Retrieve exercises for each week
          QuerySnapshot exerciseSnapshot = await _firebase
              .collection('plan')
              .doc(planId)
              .collection('week')
              .doc(weekDoc.id)
              .collection('ejercicio')
              .get();
          List<Ejercicio> ejercicios = exerciseSnapshot.docs.map((exeDoc) {
            return Ejercicio.fromDocument(
                exeDoc.id, exeDoc.data() as Map<String, dynamic>);
          }).toList();

          return Week.fromDocument(
              weekDoc.id, weekDoc.data() as Map<String, dynamic>, ejercicios);
        }).toList());

        // Create and return the Plan object
        return Plan.fromDocument(
            planDoc.id, planDoc.data() as Map<String, dynamic>, weeks);
      } else {
        // Document not found
        log.d('Plan with ID $planId does not exist');
        return null;
      }
    } catch (e) {
      // Handle any errors
      log.e('Error retrieving plan: $e');
      return null;
    }
  }

  //tested
  Future<List<Plan>> getPlanesList() async {
    final prefs = SharedPrefsHelper();
    final querySnapshot = await _firebase.collection('plan').where('ownerId',isEqualTo: await prefs.getUserId()).get();
    List<Plan> planes = [];

    for (var doc in querySnapshot.docs) {
      CollectionReference weeksCollectionRef =
          _firebase.collection('plan').doc(doc.id).collection('week');
      QuerySnapshot weeksSnapshot = await weeksCollectionRef.get();

      List<Week> weeks =
          await Future.wait(weeksSnapshot.docs.map((weekDoc) async {
        CollectionReference exerciseCollectionRef =
            weeksCollectionRef.doc(weekDoc.id).collection('ejercicio');
        QuerySnapshot exerciseSnapshot = await exerciseCollectionRef.get();

        List<Ejercicio> ejercicios = exerciseSnapshot.docs.map((exeDoc) {
          return Ejercicio.fromDocument(
              exeDoc.id, exeDoc.data() as Map<String, dynamic>);
        }).toList();

        return Week.fromDocument(
            weekDoc.id, weekDoc.data() as Map<String, dynamic>, ejercicios);
      }).toList());

      Plan plan = Plan.fromDocument(doc.id, doc.data(), weeks);
      planes.add(plan);
    }
    return planes;
  }
  
  //tested
  Future<List<Ejercicio>> getEjerciciosDelDiaList(
      Plan plan, String week, String dia) async {
    final querySnapshot = await _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(week)
        .collection('ejercicio')
        .where('dia', isEqualTo: dia)
        .get();
    return querySnapshot.docs.map((doc) {
      return Ejercicio.fromDocument(doc.id, doc.data());
    }).toList();
  }

  //tested
  Future<void> addUsuarioARutina(
      String planId, List<UsuarioBasico> usuarios) async {
    for (final user in usuarios) {
      await _firebase
          .collection('plan')
          .doc(planId)
          .collection('subscripto')
          .doc(user.docId)
          .set(UsuarioBasico.toDocument(user));
      await asigarRutinaToUser(user.docId, planId);
      _notificationService.sendNotification(user.fcmToken, 'NUEVA RUTINA', 'Se le fue asignada una nueva rutina');
      
      final forTestinOnly = await SharedPrefsHelper().getUserId();
      final provider = NotificationProvider(_firebase);
      provider.addNotification(forTestinOnly!, 'NUEVA RUTINA', 'Se le fue asignada una nueva rutina');

    }
    notifyListeners();
  }

  Future<List<UsuarioBasico>> getUsuariosEnRutina(String planId) async {
    final usersFromStore = await _firebase
        .collection('plan')
        .doc(planId)
        .collection('subscripto')
        .get();
    return usersFromStore.docs.map((doc) {
      return UsuarioBasico.fromDocument(doc.id, doc.data());
    }).toList();
  }

  Future<void> removeUsuarioDeRutina(String planId, String userId) async {
    await _firebase
        .collection('plan')
        .doc(planId)
        .collection('subscripto')
        .doc(userId)
        .delete();
    await deleteFieldFromDocument('usuario', userId, 'rutina');
    notifyListeners();
  }

  Future<void> deleteFieldFromDocument(
      String collectionName, String documentId, String fieldName) async {
    Logger log = Logger();
    CollectionReference collectionRef = _firebase.collection(collectionName);
    DocumentReference documentRef = collectionRef.doc(documentId);

    try {
      await documentRef.update({fieldName: FieldValue.delete()});
      log.d("Field '$fieldName' deleted successfully");
    } catch (e) {
      log.e("Error deleting field '$fieldName': $e");
    }
  }

  Future<void> addWeek(int number, Plan plan) async {
    DocumentReference doc = await _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .add({'number': number});
    DocumentSnapshot docSnap = await doc.get();
    Week newWeek =
        Week.fromDocument(doc.id, docSnap.data() as Map<String, dynamic>, []);
    plan.addWeek(newWeek);
    notifyListeners();
  }

  //Add Plan
  Future<Plan> addPlan(String name, String description,
      Map<String, dynamic> weight, Map<String, dynamic> height) async {
        SharedPrefsHelper prefs = SharedPrefsHelper();
    DocumentReference doc = await _firebase.collection('plan').add({
      'name': name,
      'description': description,
      'weight': weight,
      'height': height,
      'ownerId': await prefs.getUserId(),
    });

    DocumentSnapshot docSnapshot = await doc.get();

    notifyListeners();
    return Plan.fromDocument(
        doc.id, docSnapshot.data() as Map<String, dynamic>, []);
  }

  Future<void> addEjercicioASemana(
      Plan plan,
      String weekNumber,
      String name,
      String descripcion,
      int serie,
      int? repeticion,
      int? carga,
      String? ejecucion,
      String? pausa,
      String? dia) async {
    CollectionReference subcollectionReference = _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(weekNumber)
        .collection('ejercicio');
    subcollectionReference.add({
      'nombre': name,
      'descripcion': descripcion,
      'serie': serie,
      'repeticion': repeticion,
      'carga': carga,
      'ejecucion': ejecucion,
      'pausa': pausa,
      'dia': dia
    });
    notifyListeners();
  }

  Future<void> asigarRutinaToUser(String userId, String planId) async {
    Logger log = Logger();
    try {
      await _firebase
          .collection('usuario')
          .doc(userId)
          .update({'rutina': planId});
      log.d('Document updated successfully');
    } catch (e) {
      log.e('Error updating document: $e');
    }
  }

  Future<void> updatePlan(String docId, String newName, String description,
      Map<String, dynamic> weight, Map<String, dynamic> height) async {
    _firebase.collection('plan').doc(docId).update({
      'name': newName,
      'description': description,
      'weight': weight,
      'height': height
    });
    notifyListeners();
  }

  Future<void> updateEjercicio(
    Plan plan,
    String ejercicioId,
    String weekNumber,
    String name,
    String descripcion,
    int serie,
    int? repeticion,
    int? carga,
    String? ejecucion,
    String? pausa,
  ) async {
    _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(weekNumber)
        .collection('ejercicio')
        .doc(ejercicioId)
        .update({
      'nombre': name,
      'descripcion': descripcion,
      'serie': serie,
      'repeticion': repeticion,
      'carga': carga,
      'ejecucion': ejecucion,
      'pausa': pausa
    });
    notifyListeners();
  }

  Future<void> deleteExercisesfromWeek(String plan, String weekId) async {
    final subCollection = await _firebase
        .collection('plan')
        .doc(plan)
        .collection('week')
        .doc((weekId))
        .collection('ejercicio')
        .get();

    final batch = _firebase.batch();
    for (var document in subCollection.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  Future<void> deleteWeeksFromPlan(String plan) async {
    final subCollection =
        await _firebase.collection('plan').doc(plan).collection('week').get();
    final batch = _firebase.batch();
    for (var document in subCollection.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  Future<void> deletePlan(String docId) async {
    try {
      final docRef = _firebase.collection('plan').doc(docId);
      await deleteWeeksFromPlan(docRef.id);
      await docRef.delete();
      log.d('Plan with ID $docId has been deleted');
      notifyListeners(); // Uncomment this line if you're using a state management solution
    } catch (e) {
      log.e('Error deleting plan: $e');
    }
  }

  Future<void> deleteEjercicio(Plan plan, String weekId, String docId) async {
    await _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(weekId)
        .collection('ejercicio')
        .doc(docId)
        .delete();
    notifyListeners();
  }

  Future<void> deleteWeek(Plan plan) async {
    String idLastWeek = plan.lastWeek();
    await deleteExercisesfromWeek(plan.planId, plan.lastWeek());
    _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(idLastWeek)
        .delete();
    plan.removeWeek();
    notifyListeners();
  }

  //Actividad

  Future<void> agregarRutinaActividad(Plan plan, String actividadId) async {
    try {
      // Create a new document in the rutinaActividad collection
      await _firebase.collection('rutinaActividad').add({
        'rutinaId': plan.planId,
        'actividadId': actividadId,
      });
      log.d('New rutinaActividad document added successfully');
    } catch (e) {
      log.e('Error adding rutinaActividad document: $e');
    }
  }

  //This returns todas las actividades que involucran a un plan
  //planId esta asociado a un usuario en su Document
  //Entonces como resultado estamos mostrando todas las actividades que un usuario puede realizar con su
  //rutina asi  gnada.

  //Future<List<Actividad>> getActividadesDeRutina(String planId) async{
  /*
      // Step 1: Get actividadIds from rutinaActividad collection where planId matches
      QuerySnapshot rutinaActividadSnapshot = await _firebase
          .collection('rutinaActividad')
          .where('planId', isEqualTo: planId)
          .get();

      // Extract the actividadIds
      List<String> actividadIds = rutinaActividadSnapshot.docs.map((doc) {
        return doc['actividadId'] as String;
      }).toList();*/

  /*
      // Step 2: Get the corresponding Actividad documents
      List<Actividad> actividades = [];
      for (String actividadId in actividadIds) {
        DocumentSnapshot actividadDoc = await _firebase
            .collection('actividad')
            .doc(actividadId)
            .get();
        if (actividadDoc.exists) {
          actividades.add(Actividad.fromDocument(actividadDoc.id, actividadDoc.data() as Map<String, dynamic>));
        }
      }
      return actividades;
    } catch (e) {
      log.d('Error getting actividades de rutina: $e');
      return [];
    }
    */
  //}
}
