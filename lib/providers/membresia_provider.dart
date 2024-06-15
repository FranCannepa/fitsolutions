import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class MembresiaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  Future<List<Map<String, dynamic>>> getMembresiasOrigen() async {
    final String? origenMembresia = await prefs.getSubscripcion();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('membresia')
          .where('origenMembresia', isEqualTo: origenMembresia)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final fetchedMembresias = querySnapshot.docs.map((doc) {
          final membresiaData = doc.data();
          membresiaData['id'] = doc.id;
          return membresiaData;
        }).toList();
        return fetchedMembresias;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching membresias: $e');
      return [];
    }
  }

  Future<void> registrarMembresia(Map<String, dynamic> membresiaData) async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection('membresia').doc();
    await docRef.set(membresiaData);
  }
}
