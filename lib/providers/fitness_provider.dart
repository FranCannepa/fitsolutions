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
  final NotificationService _notificationService = NotificationService();

  FitnessProvider(FirebaseFirestore? firestore)
      : _firebase = firestore ?? FirebaseFirestore.instance {
    _firebase.collection('plan').snapshots().listen((snapshot) {
      notifyListeners();
    });
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
    final querySnapshot = await _firebase
        .collection('plan')
        .where('ownerId', isEqualTo: await prefs.getUserId())
        .get();
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
      if (user.rutina != '') {
        await removeUsuarioDeRutina(user.rutina, user.docId);
      }

      await _firebase
          .collection('plan')
          .doc(planId)
          .collection('subscripto')
          .doc(user.docId)
          .set(UsuarioBasico.toDocument(user));
      await asigarRutinaToUser(user.docId, planId);

      _notificationService.sendNotification(
          user.fcmToken, 'NUEVA RUTINA', 'Se le fue asignada una nueva rutina');

      final provider = NotificationProvider(_firebase);
      provider.addNotification(user.docId, 'NUEVA RUTINA',
          'Se le fue asignada una nueva rutina', '/ejercicios');
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
    Week newWeek =Week.fromDocument(doc.id, docSnap.data() as Map<String, dynamic>, []);
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
    final list = await _firebase
        .collection('usuario')
        .where('rutina', isEqualTo: plan.planId)
        .get();

    final provider = NotificationProvider(_firebase);

    for (var user in list.docs) {
      _notificationService.sendNotification(
          user.get('fcmToken'),
          'NUEVO EJERCICIO',
          'Un nuevo ejercicio fue agregado a $weekNumber - $dia');
      provider.addNotification(
          user.id,
          'NUEVO EJERCICIO',
          'Un nuevo ejercicio fue agregado a $weekNumber - $dia',
          '/ejercicios');
    }
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
      //Borra Rutina para cada Usuario
      notifyListeners();
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

  Future<void> initializeWorkoutState(
      Plan plan, List<String> daysNames) async {

    final userType = await SharedPrefsHelper().getUserTipo();
    if(userType != 'Basico') return;

    List<Week> weeks = plan.weeks;
    for (var week in weeks) {
      final userId = await SharedPrefsHelper().getUserId();
      final userRef = _firebase.collection('workoutStates').doc(userId);
      final weekRef = userRef.collection('weeks').doc(week.id);

      // Check if the week document exists
      final weekSnapshot = await weekRef.get();
      if (!weekSnapshot.exists) {
        // If the week document doesn't exist, initialize it with empty data
        await weekRef.set({});
        Map<String, dynamic> initialDays = {};
        bool weekState = true;
        for (var day in daysNames) {
          final ejercicios = await getEjerciciosDelDiaList(plan, week.id!, day);
          for (final ejercicio in ejercicios) {
            await updateExerciseInFirestore(week.id!, ejercicio, day);
          }
          initialDays[day] = ejercicios.isEmpty ? true : false;
          weekState = weekState && initialDays[day];
        }

        await weekRef.update({
          'daysCompleted': initialDays,
          'weekCompleted': weekState,
        });
      } else {
        // If the week document exists, ensure each day exists in daysCompleted
        final data = weekSnapshot.data() as Map<String, dynamic>;
        final daysCompleted = data['daysCompleted'] as Map<String, dynamic>?;

        if (daysCompleted == null) {
          // If daysCompleted doesn't exist, initialize all days
          Map<String, dynamic> initialDays = {};
          for (var day in daysNames) {
            initialDays[day] = false;
          }

          await weekRef.update({
            'daysCompleted': initialDays,
          });
        } else {
          // Initialize any missing days
          for (var day in daysNames) {
            if (!daysCompleted.containsKey(day)) {
              await weekRef.update({
                'daysCompleted.$day': false,
              });
            }
          }
        }
      }
    }
  }

  Future<void> updateExerciseCompletion(
      String weekId, String exerciseId, bool completed, String day) async {
    final userId = await SharedPrefsHelper().getUserId();
    final docRef = _firebase
        .collection('workoutStates')
        .doc(userId)
        .collection('weeks')
        .doc(weekId);

    await docRef.set({
      'exercises': {
        exerciseId: {'completed': completed, 'day': day}
      },
    }, SetOptions(merge: true));

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final exercises = data['exercises'] as Map<String, dynamic>;
      final dayExercises =
          exercises.values.where((exercise) => exercise['day'] == day);
      if (dayExercises.every((exercise) => exercise['completed'])) {
        await docRef.update({'daysCompleted.$day': true});
        checkIfWeekCompleted(userId!, weekId);
      } else {
        await docRef.update({'daysCompleted.$day': false});
        await docRef.update({'weekCompleted': false});
        notifyListeners();
      }
    }
  }

  Future<void> checkIfWeekCompleted(String userId, String weekId) async {
    final weekRef = _firebase
        .collection('workoutStates')
        .doc(userId)
        .collection('weeks')
        .doc(weekId);

    final docSnapshot = await weekRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final daysCompletedDynamic =
          data['daysCompleted'] as Map<String, dynamic>;

      final daysCompleted = daysCompletedDynamic
          .map((key, value) => MapEntry(key, value as bool));

      if (daysCompleted.values.every((isCompleted) => isCompleted)) {
        await weekRef.update({'weekCompleted': true});
      } else {
        await weekRef.update({'weekCompleted': false});
      }
      notifyListeners();
    }
  }

  Future<void> updateExerciseInFirestore(
      String weekId, Ejercicio ejercicio, String day) async {
    final userId = await SharedPrefsHelper().getUserId();
    final docRef = _firebase
        .collection('workoutStates')
        .doc(userId)
        .collection('weeks')
        .doc(weekId);

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final exercises = data['exercises'] as Map<String, dynamic>? ?? {};

      if (!exercises.containsKey(ejercicio.id)) {
        // Add the exercise if it doesn't exist
        await docRef.update({
          'exercises.${ejercicio.id}': {
            'completed': false,
            'day': day,
          },
        });
      }
      /*if (!(data['daysCompleted'] as Map<String, dynamic>?)!.containsKey(day)) {
        await docRef.update({
          'daysCompleted.$day': false,
        });
      }*/
    }
  }

  Future<Map<String, bool>> initializeCheckBox(String weekId) async {
    Map<String, bool> checkedExercises = {};
    final userId = await SharedPrefsHelper().getUserId();
    final docRef = _firebase
        .collection('workoutStates')
        .doc(userId)
        .collection('weeks')
        .doc(weekId);
    final docSnapshot = await docRef.get();
    final Map<String, dynamic>? workoutState = docSnapshot.data();
    // Initialize _checkedExercises based on Firestore data
    if (workoutState != null && workoutState.containsKey('exercises')) {
      final Map<String, dynamic> exercises = workoutState['exercises'];
      checkedExercises.clear();
      exercises.forEach((exerciseId, exerciseData) {
        if (exerciseData is Map<String, dynamic> &&
            exerciseData.containsKey('completed')) {
          checkedExercises[exerciseId] = exerciseData['completed'];
        }
      });
    }
    return checkedExercises;
  }

  Future<bool> isWeekCompleted(String weekId) async {
    try {
      final userId = await SharedPrefsHelper().getUserId();
      DocumentSnapshot weekDoc = await FirebaseFirestore.instance
          .collection('workoutStates')
          .doc(userId)
          .collection('weeks')
          .doc(weekId)
          .get();

      if (weekDoc.exists) {
        bool weekCompleted = weekDoc.get('weekCompleted');
        if (weekCompleted) {
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      log.d(e);
      return false;
    }
  }

  Future<bool> isDayCompleted(String weekId, String day) async {
    try {
      // Fetch the document corresponding to the week
      final userId = await SharedPrefsHelper().getUserId();
      DocumentSnapshot weekDoc = await FirebaseFirestore.instance
          .collection('workoutStates')
          .doc(userId)
          .collection('weeks')
          .doc(weekId)
          .get();

      if (weekDoc.exists) {
        // Retrieve the week document data
        Map<String, dynamic> weekData = weekDoc.data() as Map<String, dynamic>;

        // Check if the specific day is completed
        if (weekData.containsKey('daysCompleted')) {
          Map<String, bool> daysCompleted =
              Map<String, bool>.from(weekData['daysCompleted']);
          return daysCompleted[day] ?? false;
        } else {
          return false; // If daysCompleted key is missing
        }
      } else {
        return false; // If the document does not exist, treat it as not completed
      }
    } catch (e) {
      // Handle any errors (e.g., Firestore permission issues)
      log.d('Error checking day completion: $e');
      return false;
    }
  }
}
