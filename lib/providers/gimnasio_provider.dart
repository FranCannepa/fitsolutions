import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/Modelo/Gimnasio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GimnasioProvider extends ChangeNotifier {
  Logger log = Logger();
  final prefs = SharedPrefsHelper();

  Future<Gimnasio?> getGym() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: await prefs.getUserId())
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        final data = docSnapshot.data();
        data['gimnasioId'] = docSnapshot.id;
        return Gimnasio.fromDocument(data);
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error getting gym data: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getClientesGym(String gymId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuario')
          .where('asociadoId', isEqualTo: gymId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> usuarios = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          data['usuarioId'] = doc.id;
          usuarios.add(data);
        }
        return usuarios;
      } else {
        return [];
      }
    } catch (e) {
      log.d("Error getting usuarios data: $e");
      return [];
    }
  }
}
