import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class ActividadProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  Future<List<Map<String, dynamic>>> fetchActividades(DateTime fecha) async {
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
          actividadData['id'] = doc.id;
          return actividadData;
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
  // Future<List<Map<String, dynamic>>> fetchPlanes(String idActividad) async {
  //   final String? usuarioId = await prefs.getUserId();
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('actividad')
  //         .where('propietarioActividadId', isEqualTo: ownerActividades)
  //         .where('inicio', isGreaterThanOrEqualTo: todayStart)
  //         .where('fin', isLessThanOrEqualTo: todayEnd)
  //         .get();
  //     if (querySnapshot.docs.isNotEmpty) {
  //       final fetchedActividades = querySnapshot.docs.map((doc) {
  //         final actividadData = doc.data();
  //         actividadData['id'] = doc.id;
  //         return actividadData;
  //       }).toList();
  //       return fetchedActividades;
  //     } else {
  //       return [];
  //     }
  //   } catch (e) {
  //     print('Error fetching actividades: $e');
  //     return [];
  //   }
  // }
}
