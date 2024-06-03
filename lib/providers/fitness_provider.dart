
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

  Future<List<Plan>> getPlanesList() async {

    final querySnapshot = await planCollection.get();
    List<Plan> planes = [];

    for( var doc in querySnapshot.docs){
      CollectionReference weeksCollectionRef = planCollection.doc(doc.id).collection('week');
      QuerySnapshot weeksSnapshot = await weeksCollectionRef.get();

      List<Week> weeks = weeksSnapshot.docs.map((weekDoc){
        return Week.fromDocument(weekDoc.id, weekDoc.data() as Map<String,dynamic>);
      }).toList();

      Plan plan = Plan.fromDocument(doc.id, doc.data(), weeks);
      planes.add(plan);

    };
    return planes;
  }

  Future<List<Ejercicio>> getEjerciciosList(Plan plan) async {
    final querySnapshot =
        await planCollection.doc(plan.planId).collection('ejercicio').get();
    return querySnapshot.docs.map((doc) {
      return Ejercicio.fromDocument(doc.id, doc.data());
    }).toList();
  }

  Future<List<Ejercicio>> getEjerciciosDelDiaList(Plan plan, String week, String dia) async{
    final querySnapshot = await planCollection.doc(plan.planId).collection('week').doc(week).collection('ejercicio').where('dia',isEqualTo: dia).get();
    return querySnapshot.docs.map((doc){
      return Ejercicio.fromDocument(doc.id, doc.data());
    }).toList();
  }

  Future<void> addWeek(int number, Plan plan) async{
    DocumentReference doc = await planCollection.doc(plan.planId).collection('week').add({
      'number':number
    });
    DocumentSnapshot docSnap = await doc.get();
    Week newWeek = Week.fromDocument(doc.id, docSnap.data() as Map<String,dynamic>);
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
        doc.id, docSnapshot.data() as Map<String, dynamic>,[]);
  }

  //Add exercise to Plan
  Future<void> addEjercicio(Plan plan, String name,String descripcion, int serie, int? repeticion, int? carga, int ejecucion, int? pausa,String? dia) async {
    CollectionReference subcollectionReference =
        planCollection.doc(plan.planId).collection('ejercicio');
    subcollectionReference.add({
      'nombre': name,
      'descripcion': descripcion,
      'serie' : serie,
      'repeticion': repeticion,
      'carga' : carga,
      'ejecucion': ejecucion,
      'pausa': pausa,
      'dia': dia
    });
    notifyListeners();
  }

  Future<void> addEjercicioASemana(Plan plan, String weekNumber, String name,String descripcion, int serie, int? repeticion, int? carga, int ejecucion, int? pausa,String? dia) async {
    CollectionReference subcollectionReference =
        planCollection.doc(plan.planId).collection('week').doc(weekNumber).collection('ejercicio');
    subcollectionReference.add({
      'nombre': name,
      'descripcion': descripcion,
      'serie' : serie,
      'repeticion': repeticion,
      'carga' : carga,
      'ejecucion': ejecucion,
      'pausa': pausa,
      'dia': dia
    });
    notifyListeners();
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

  Future<void> updateEjercicio(Plan plan, String docId, String newName, String description,
  ) async{
    planCollection.doc(plan.planId).collection('ejercicio').doc(docId).update({
      'nombre': newName,
    });
  }

  Future<void> deletePlan(String docId) async {
    await planCollection.doc(docId).delete();
    notifyListeners();
  }

  Future<void> deleteEjercicio(Plan plan, String docId) async{
    await planCollection.doc(plan.planId).collection('ejercicio').doc(docId).delete();
    notifyListeners();
  } 

  Future<void> deleteWeek(Plan plan) async{
    await planCollection.doc(plan.planId).collection('week').doc(plan.lastWeek()).delete();
    plan.removeWeek();
    notifyListeners();
  }

  bool planTieneEjercicios(Plan plan) {
    return plan.ejercicios.isNotEmpty;
  }
}
