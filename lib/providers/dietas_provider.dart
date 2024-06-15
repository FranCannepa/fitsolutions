import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class DietaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  final query = FirebaseFirestore.instance;

  Future<Dieta?> getDieta() async {
    final userId = await prefs.getUserId();
    final userDocRef = query.collection('usuario').doc(userId);
    final userDocSnapshot = await userDocRef.get();
    if (userDocSnapshot.exists) {
      final userData = userDocSnapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('dietaId')) {
        final dietaId = userData['dietaId'] as String;
        final dietaDocRef = query.collection('dieta').doc(dietaId);
        final dietaDocSnapshot = await dietaDocRef.get();
        if (dietaDocSnapshot.exists) {
          final dietaData = dietaDocSnapshot.data() as Map<String, dynamic>;
          final dieta = Dieta.fromDocument(dietaData);
          return dieta;
        } else {
          print("Dieta document not found for user ID: $userId");
          return null;
        }
      } else {
        print("User data does not contain 'dietaId' key");
        return null;
      }
    } else {
      print("User document not found for user ID: $userId");
      return null;
    }
  }

  Future<List<Dieta>> getDietas() async {
    final firestore = FirebaseFirestore.instance;
    final String? origenMembresia = await prefs.getSubscripcion();
    try {
      final dietQuery = firestore
          .collection('dieta')
          .where('origenDieta', isEqualTo: origenMembresia);
      final querySnapshot = await dietQuery.get();
      final List<Dieta> dietas = [];
      for (var doc in querySnapshot.docs) {
        final dietaData = doc.data();
        final dieta = Dieta.fromDocument({
          ...dietaData,
          "dietaId": doc.id,
        });
        dietas.add(dieta);
      }
      return dietas;
    } catch (error) {
      print("Error fetching dietas: $error");
      return [];
    }
  }
}
