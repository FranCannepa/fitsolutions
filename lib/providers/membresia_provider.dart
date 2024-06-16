import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class MembresiaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  Future<List<Membresia>> getMembresiasOrigen() async {
    final String? origenMembresia = await prefs.getSubscripcion();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('membresia')
          .where('origenMembresia', isEqualTo: origenMembresia)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final fetchedMembresias = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['membresiaId'] = doc.id;
          return Membresia.fromDocument(data);
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

  Future<bool> registrarMembresia(Map<String, dynamic> membresiaData) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('membresia').doc();
      await docRef.set(membresiaData);
      return true;
    } on FirebaseException catch (e) {
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
