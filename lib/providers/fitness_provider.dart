import 'dart:async';

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
  final SharedPrefsHelper prefs;
  final NotificationService _notificationService = NotificationService();
  final List<StreamSubscription> _subscriptions = [];

  FitnessProvider(FirebaseFirestore? firestore, this.prefs)
      : _firebase = firestore ?? FirebaseFirestore.instance {
    _firebase.collection('plan').snapshots().listen((snapshot) {
      notifyListeners();
      _listenToWeekSubcollections(snapshot);
    });
  }
//Seguramente aqui alla que utilizar el id del plan para escuchar cambios en un plan especifico
// - Ryan
  void _listenToWeekSubcollections(QuerySnapshot planSnapshot) {
    // Cancel previous subscriptions to avoid duplicate listeners
    _cancelSubscriptions();

    for (var doc in planSnapshot.docs) {
      var planId = doc.id;
      var weekSubcollectionRef =
          _firebase.collection('plan').doc(planId).collection('week');
      var subscriptoSubcollectionRef =
          _firebase.collection('plan').doc(planId).collection('subscripto');

      // Listen to the 'week' subcollection
      var weekSubscription =
          weekSubcollectionRef.snapshots().listen((weekSnapshot) {
        notifyListeners(); // Notify listeners about changes in the week subcollection

        // Loop through each document in the 'week' subcollection
        for (var weekDoc in weekSnapshot.docs) {
          var weekId = weekDoc.id;
          var ejercicioSubcollectionRef =
              weekSubcollectionRef.doc(weekId).collection('ejercicio');

          // Listen to the 'ejercicio' subcollection
          var ejercicioSubscription =
              ejercicioSubcollectionRef.snapshots().listen((ejercicioSnapshot) {
            notifyListeners(); // Notify listeners about changes in the ejercicio subcollection
          });

          _subscriptions.add(ejercicioSubscription);
        }
      });

      // Listen to the 'subscripto' subcollection
      var subscriptoSubscription =
          subscriptoSubcollectionRef.snapshots().listen((subscriptoSnapshot) {
        notifyListeners(); // Notify listeners about changes in the subscripto subcollection
      });

      // Add subscriptions to the list
      _subscriptions.add(weekSubscription);
      _subscriptions.add(subscriptoSubscription);
    }
  }

  void _cancelSubscriptions() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  Future<Plan?> getRutinaDeUsuario(String docId) async {
    CollectionReference collectionRef = _firebase.collection('usuario');
    DocumentReference documentRef = collectionRef.doc(docId);
    final dataUser = await documentRef.get();
    Map<String, dynamic> data = dataUser.data() as Map<String, dynamic>;
    if (data['rutina'] == null) return null;
    Plan? plan = await getPlanById(data['rutina']);
    return plan;
  }

  //tested
  Future<Plan?> getPlanById(String? planId) async {
    Logger log = Logger();
    try {
      if (planId == null) return null;
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
            .orderBy('number')
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
    final userId = await prefs.getUserId();
    final querySnapshot = await _firebase
        .collection('plan')
        .where('ownerId', isEqualTo: userId)
        .get();

    List<Plan> planes = [];

    for (var doc in querySnapshot.docs) {
      CollectionReference weeksCollectionRef =
          _firebase.collection('plan').doc(doc.id).collection('week');

      // Retrieve weeks sorted by the 'number' field
      QuerySnapshot weeksSnapshot = await weeksCollectionRef
          .orderBy('number') // Order weeks by the 'number' field
          .get();

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

  Future<List<Ejercicio>> getEjercicios() async {
    final query = await _firebase.collection('ejercicio').get();
    return query.docs.map((doc) {
      return Ejercicio.fromDocument(doc.id, doc.data());
    }).toList();
  }

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

      final provider = NotificationProvider(_firebase,SharedPrefsHelper());
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
    try {
      // Reference to the subscripto document
      var subscriptoDocRef = _firebase
          .collection('plan')
          .doc(planId)
          .collection('subscripto')
          .doc(userId);

      // Check if the document exists
      DocumentSnapshot subscriptoDoc = await subscriptoDocRef.get();
      if (subscriptoDoc.exists) {
        // Document exists, proceed with deletion
        await subscriptoDocRef.delete();
      } else {
        // Document does not exist
        return;
      }
      // Perform the deleteFieldFromDocument operation regardless of existence
      await deleteFieldFromDocument('usuario', userId, 'rutina');
      notifyListeners(); // Notify listeners after the operations
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> eliminarRutinaRemoverAsignacion(String planId) async {
    final docRef = await _firebase
        .collection('plan')
        .doc(planId)
        .collection('subscripto')
        .get();
    final batch = _firebase.batch();
    for (var document in docRef.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();

    final users = await _firebase
        .collection('usuario')
        .where('rutina', isEqualTo: planId)
        .get();
    for (var u in users.docs) {
      await deleteFieldFromDocument('usuario', u.id, 'rutina');
    }
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

  Future<void> addEjercicio(String name, String descripcion, int serie,
      int? repeticion, int? carga, String? ejecucion, String? pausa) async {
    CollectionReference ejercicios =
       _firebase.collection('ejercicio');

    QuerySnapshot existingDocs = await ejercicios
        .where('nombre', isEqualTo: name)
        .where('descripcion', isEqualTo: descripcion)
        .where('serie', isEqualTo: serie)
        .where('repeticion', isEqualTo: repeticion)
        .where('carga', isEqualTo: carga)
        .where('ejecucion', isEqualTo: ejecucion)
        .where('pausa', isEqualTo: pausa)
        .get();

    if (existingDocs.docs.isEmpty) {
      // No existing document with the same values
      await ejercicios.add({
        'nombre': name,
        'descripcion': descripcion,
        'serie': serie,
        'repeticion': repeticion,
        'carga': carga,
        'ejecucion': ejecucion,
        'pausa': pausa,
      });
      notifyListeners();
    }
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
    final newlyAdded = await subcollectionReference.add({
      'nombre': name,
      'descripcion': descripcion,
      'serie': serie,
      'repeticion': repeticion,
      'carga': carga,
      'ejecucion': ejecucion,
      'pausa': pausa,
      'dia': dia
    });

    addEjercicio(name, descripcion, serie, repeticion, carga, ejecucion, pausa);
    DocumentSnapshot newSnapshot = await newlyAdded.get();
    Ejercicio ejercicio = Ejercicio.fromDocument(
        newSnapshot.id, newSnapshot.data() as Map<String, dynamic>);
    await updateExerciseForSubscribedUsers(
        plan.planId, weekNumber, ejercicio, dia!);
    final list = await _firebase
        .collection('usuario')
        .where('rutina', isEqualTo: plan.planId)
        .get();
    final provider = NotificationProvider(_firebase,SharedPrefsHelper());

    // Fetch the week document to get the value number
    DocumentSnapshot weekSnapshot = await _firebase
        .collection('plan')
        .doc(plan.planId)
        .collection('week')
        .doc(weekNumber)
        .get();

    for (var user in list.docs) {
      _notificationService.sendNotification(
          user.get('fcmToken'),
          'NUEVO EJERCICIO',
          'Un nuevo ejercicio fue agregado a Semana ${weekSnapshot['number']} - Dia $dia');
      provider.addNotification(
          user.id,
          'NUEVO EJERCICIO',
          'Un nuevo ejercicio fue agregado a Semana ${weekSnapshot['number']} - Dia $dia',
          '/ejercicios');
    }
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

  Future<void> updateEjercicioCollection(
    String ejercicioId,
    String name,
    String descripcion,
    int serie,
    int? repeticion,
    int? carga,
    String? ejecucion,
    String? pausa,
  ) async {
    _firebase.collection('ejercicio').doc(ejercicioId).update({
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
      eliminarRutinaRemoverAsignacion(docId);
      notifyListeners();
    } catch (e) {
      log.e('Error deleting plan: $e');
    }
  }

  Future<void> deleteEjercicioCollection(String id) async {
    await _firebase.collection('ejercicio').doc(id).delete();
    notifyListeners();
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
    await deleteExerciseFromWorkoutState(weekId, docId);
    notifyListeners();
  }

  Future<void> deleteExerciseFromWorkoutState(
      String weekId, String exerciseId) async {
    final usersSnapshot = await _firebase.collection('workoutStates').get();
    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final weekSnapshot = await _firebase
          .collection('workoutStates')
          .doc(userId)
          .collection('weeks')
          .doc(weekId)
          .get();

      if (weekSnapshot.exists) {
        final weekData = weekSnapshot.data() as Map<String, dynamic>;
        if (weekData.containsKey('exercises')) {
          final exercises = weekData['exercises'] as Map<String, dynamic>;
          final day = exercises[exerciseId]['day'];

          if (exercises.containsKey(exerciseId)) {
            exercises.remove(exerciseId);

            // Check if there are no more exercises for that day
            bool noExercisesForDay =
                !exercises.values.any((exercise) => exercise['day'] == day);
            if (noExercisesForDay) {
              weekData['daysCompleted'][day] = true;
            }

            // Check if all days are completed
            bool allDaysCompleted = weekData['daysCompleted']
                .values
                .every((completed) => completed == true);
            if (allDaysCompleted) {
              weekData['weekCompleted'] = true;
            }

            await _firebase
                .collection('workoutStates')
                .doc(userId)
                .collection('weeks')
                .doc(weekId)
                .update({
              'exercises': exercises,
              'daysCompleted': weekData['daysCompleted'],
              'weekCompleted': weekData['weekCompleted']
            });
          }
        }
      }
    }
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

  Future<void> initializeWorkoutState(Plan plan, List<String> daysNames) async {
    final userType = await prefs.getUserTipo();
    if (userType != 'Basico') return;
    try {
      List<Week> weeks = plan.weeks;
      for (var week in weeks) {
        final userId = await prefs.getUserId();
        final userRef = _firebase.collection('workoutStates').doc(userId);
        final snapshot = await userRef.get();
        if (!snapshot.exists) userRef.set({'plan': plan.planId});

        final weekRef = userRef.collection('weeks').doc(week.id);

        // Check if the week document exists
        final weekSnapshot = await weekRef.get();
        if (!weekSnapshot.exists) {
          // If the week document doesn't exist, initialize it with empty data
          await weekRef.set({});
          Map<String, dynamic> initialDays = {};
          bool weekState = true;
          for (var day in daysNames) {
            final ejercicios =
                await getEjerciciosDelDiaList(plan, week.id!, day);
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
    } catch (e) {
      Logger().e(e);
    }
  }

  Future<void> updateExerciseCompletion(
      String weekId, String exerciseId, bool completed, String day) async {
    final userId = await prefs.getUserId();
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
    final userId = await prefs.getUserId();
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

  Future<void> updateExerciseForSubscribedUsers(
      String planId, String weekId, Ejercicio ejercicio, String day) async {
    final subscriptoCollection =
        _firebase.collection('plan').doc(planId).collection('subscripto');

    final querySnapshot = await subscriptoCollection.get();

    for (var doc in querySnapshot.docs) {
      final userId = doc.id;

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
            'weekCompleted': false,
          });

          await docRef.update({
            'daysCompleted.$day': false,
          });
        }
      }
    }
  }

  Future<Map<String, bool>> initializeCheckBox(String weekId) async {
    Map<String, bool> checkedExercises = {};
    final userId = await prefs.getUserId();
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
      final userId = await prefs.getUserId();
      DocumentSnapshot weekDoc = await _firebase
          .collection('workoutStates')
          .doc(userId)
          .collection('weeks')
          .doc(weekId)
          .get();

      if (weekDoc.exists) {
        final weekData = weekDoc.data() as Map<String, dynamic>;
        if (weekData.containsKey('weekCompleted')) {
          bool weekCompleted = weekDoc.get('weekCompleted');
          if (weekCompleted) {
            return true;
          }
          return false;
        }
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
      final userId = await prefs.getUserId();
      DocumentSnapshot weekDoc = await _firebase
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
