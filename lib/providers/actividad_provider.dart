import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class ActividadProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();

   ActividadProvider(){
    FirebaseFirestore.instance.collection('actividad').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }
  
  Future<List<Actividad>> fetchActividades(DateTime fecha) async {
    String? ownerActividades = await prefs.getSubscripcion();
    try {
      final todayStart = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: ownerActividades)
          .where('inicio', isGreaterThanOrEqualTo: todayStart)
          .where('fin', isLessThanOrEqualTo: todayEnd)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final fetchedActividades = querySnapshot.docs.map((doc) {
          final actividadData = doc.data();
          actividadData['actividadId'] = doc.id;
          return Actividad.fromDocument(actividadData);
        }).toList();
        return fetchedActividades;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching actividades: $e');
      return [];
    }
  }

  Future<bool> registrarActividad(Map<String, dynamic> actividadData) async {
    try {
      await FirebaseFirestore.instance
          .collection('actividad')
          .add(actividadData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      rethrow;
    }
  }
}
