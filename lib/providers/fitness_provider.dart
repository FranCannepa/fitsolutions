import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../modelo/models.dart';

class FitnessProvider extends ChangeNotifier {
  Logger log = Logger();
  final planCollection = FirebaseFirestore.instance.collection('plan');

  FitnessProvider() {
    planCollection.snapshots().listen((snapshot) {
      notifyListeners();
    });
  }

  Future<List<UsuarioBasico>> getUsuariosInscriptos(String rutinaId) async {
    //This filter should be different.
    //Here we should filter by users that are members of the gym.
    //Y que este habiles.
    CollectionReference userStore =
        FirebaseFirestore.instance.collection('usuario');
    QuerySnapshot userSnapshot =
        await userStore.where('tipo', isEqualTo: 'Basico').get();

    List<UsuarioBasico> users = userSnapshot.docs.map((userDoc) {
      return UsuarioBasico.fromDocument(
          userDoc.id, userDoc.data() as Map<String, dynamic>);
    }).toList();
    return users;
  }

  Future<Plan> getRutinaDeUsuario(String docId) async {
    CollectionReference rutinaCol = FirebaseFirestore.instance
        .collection('usuario')
        .doc(docId)
        .collection('rutinaUsuario');
    QuerySnapshot rutina = await rutinaCol.limit(1).get();
    List<Week> weeks;
    for (var doc in rutina.docs) {
      QuerySnapshot weeksSnapshot =
          await rutinaCol.doc(doc.id).collection('week').get();
      weeks = weeksSnapshot.docs.map((weekDoc) {
        return Week.fromDocument(
            weekDoc.id, weekDoc.data() as Map<String, dynamic>);
      }).toList();
      return Plan.fromDocument(
          doc.id, doc.data() as Map<String, dynamic>, weeks);
    }
    throw Exception('No data found');
  }

  Future<List<Plan>> getPlanesList() async {
    final querySnapshot = await planCollection.get();
    List<Plan> planes = [];

    for (var doc in querySnapshot.docs) {
      CollectionReference weeksCollectionRef =
          planCollection.doc(doc.id).collection('week');
      QuerySnapshot weeksSnapshot = await weeksCollectionRef.get();

      List<Week> weeks = weeksSnapshot.docs.map((weekDoc) {
        return Week.fromDocument(
            weekDoc.id, weekDoc.data() as Map<String, dynamic>);
      }).toList();

      Plan plan = Plan.fromDocument(doc.id, doc.data(), weeks);
      planes.add(plan);
    }
    ;
    return planes;
  }

  Future<List<Ejercicio>> getEjerciciosDelDiaList(
      Plan plan, String week, String dia) async {
    final querySnapshot = await planCollection
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

  Future<void> addUsuarioARutina(
      String planId, List<UsuarioBasico> usuarios) async {
    for (final user in usuarios) {
      await planCollection
          .doc(planId)
          .collection('subscripto')
          .doc(user.docId)
          .set(UsuarioBasico.toDocument(user));
      await copyRutinaToUser(user.docId, planId);
    }
    notifyListeners();
  }

  Future<List<UsuarioBasico>> getUsuariosEnRutina(String planId) async {
    final usersFromStore =
        await planCollection.doc(planId).collection('subscripto').get();
    return usersFromStore.docs.map((doc) {
      return UsuarioBasico.fromDocument(doc.id, doc.data());
    }).toList();
  }

  Future<void> removeUsuarioDeRutina(String planId, String userId) async {
    await planCollection
        .doc(planId)
        .collection('subscripto')
        .doc(userId)
        .delete();
    await deletePlanFromUser(planId, userId);
    notifyListeners();
  }

  Future<void> addWeek(int number, Plan plan) async {
    DocumentReference doc = await planCollection
        .doc(plan.planId)
        .collection('week')
        .add({'number': number});
    DocumentSnapshot docSnap = await doc.get();
    Week newWeek =
        Week.fromDocument(doc.id, docSnap.data() as Map<String, dynamic>);
    plan.addWeek(newWeek);
    notifyListeners();
  }

  //Add Plan
  Future<Plan> addPlan(String name, String description,
      Map<String, dynamic> weight, Map<String, dynamic> height) async {
    DocumentReference doc = await planCollection.add({
      'name': name,
      'description': description,
      'weight': weight,
      'height': height
    });

    DocumentSnapshot docSnapshot = await doc.get();

    notifyListeners();
    return Plan.fromDocument(
        doc.id, docSnapshot.data() as Map<String, dynamic>, []);
  }

  //Add exercise to Plan
  Future<void> addEjercicio(
      Plan plan,
      String name,
      String descripcion,
      int serie,
      int? repeticion,
      int? carga,
      int ejecucion,
      int? pausa,
      String? dia) async {
    CollectionReference subcollectionReference =
        planCollection.doc(plan.planId).collection('ejercicio');
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
    CollectionReference subcollectionReference = planCollection
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

  Future<void> copyRutinaToUser(String userId, String planId) async {
    //copy workout
    final rutinaRef = planCollection.doc(planId);
    DocumentSnapshot rutina = await planCollection.doc(planId).get();

    final rutinaData = rutina.data() as Map<String, dynamic>;

    final rutinaUserRef = FirebaseFirestore.instance
        .collection('usuario')
        .doc(userId)
        .collection('rutinaUsuario')
        .doc(planId);
    rutinaUserRef.set(rutinaData);
    //copy the week
    final weekSnapshot = await rutinaRef.collection('week').get();
    for (final week in weekSnapshot.docs) {
      final weekData = week.data();
      rutinaUserRef.collection('week').doc(week.id).set(weekData);
      final exerciseSnapshot = await rutinaRef
          .collection('week')
          .doc(week.id)
          .collection('ejercicio')
          .get();

      for (final exercise in exerciseSnapshot.docs) {
        final exerciseData = exercise.data();
        rutinaUserRef
            .collection('week')
            .doc(week.id)
            .collection('ejercicio')
            .doc(exercise.id)
            .set(exerciseData);
      }
    }
  }

  Future<void> updatePlan(String docId, String newName, String description,
      Map<String, dynamic> weight, Map<String, dynamic> height) async {
    planCollection.doc(docId).update({
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
    planCollection
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
    final subCollection = await FirebaseFirestore.instance
        .collection('plan')
        .doc(plan)
        .collection('week')
        .doc((weekId))
        .collection('ejercicio')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var document in subCollection.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }

  Future<void> deleteWeeksFromPlan(String plan) async {
    final subCollection = await FirebaseFirestore.instance
        .collection('plan')
        .doc(plan)
        .collection('week')
        .get();
    for (var document in subCollection.docs) {
      await deleteExercisesfromWeek(plan, document.id);
      await document.reference.delete();
    }
  }

  Future<void> deleteWeeksFromRutinaUser(String plan, String userId) async {
    final subCollection = await FirebaseFirestore.instance
        .collection('usuario')
        .doc(userId)
        .collection('rutinaUsuario')
        .doc(plan)
        .collection('week')
        .get();
    for (var document in subCollection.docs) {
      await deleteExercisesfromWeek(plan, document.id);
      await document.reference.delete();
    }
  }

  Future<void> deletePlan(String docId) async {
    final docRef = planCollection.doc(docId);
    await deleteWeeksFromPlan(docRef.id);
    docRef.delete();
    notifyListeners();
  }

  Future<void> deletePlanFromUser(String rutinaId, String docId) async {
    final rutinaRef = FirebaseFirestore.instance
        .collection('usuario')
        .doc(docId)
        .collection('rutinaUsuario');
    await deleteWeeksFromRutinaUser(rutinaId, docId);
    rutinaRef.doc(rutinaId).delete();
    notifyListeners();
  }

  Future<void> deleteEjercicio(Plan plan, String weekId, String docId) async {
    await planCollection
        .doc(plan.planId)
        .collection('week')
        .doc(weekId)

        .collection('ejercicio')
        .doc(docId)
        .delete();
    notifyListeners();
  }

  Future<void> deleteWeek(Plan plan) async {
    await deleteExercisesfromWeek(plan.planId, plan.lastWeek());
    plan.removeWeek();
    notifyListeners();
  }

  bool planTieneEjercicios(Plan plan) {
    return plan.ejercicios.isNotEmpty;
  }
}
