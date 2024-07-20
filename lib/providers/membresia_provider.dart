import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';

class MembresiaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  Future<List<Membresia>> getMembresiasOrigen() async {
    final String? origenMembresia = await prefs.getSubscripcion();
    if (origenMembresia != null && origenMembresia != '') {
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
    return [];
  }

  Future<Map<String, dynamic>?> getOrigenMembresia(String documentId) async {
    try {
      final usuarioRef =
          FirebaseFirestore.instance.collection('usuario').doc(documentId);
      final usuarioSnapshot = await usuarioRef.get();

      if (usuarioSnapshot.exists) {
        final data = usuarioSnapshot.data()!;
        return {
          ...data,
          'origenTipo': 'Entrenador',
        };
      }
      final gimnasioRef =
          FirebaseFirestore.instance.collection('gimnasio').doc(documentId);
      final gimnasioSnapshot = await gimnasioRef.get();
      if (gimnasioSnapshot.exists) {
        final data = gimnasioSnapshot.data()!;
        final nombreOrigen = data['nombreGimnasio'];
        return {
          'nombreOrigen': nombreOrigen,
          'origenTipo': 'Gimnasio',
        };
      }
      return null;
    } catch (e) {
      print("Error fetching origen membership: $e");
      return null;
    }
  }

  Future<bool> registrarMembresia(Map<String, dynamic> membresiaData) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('membresia').doc();
      await docRef.set(membresiaData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<Map<String, String>> getKeys(String gimnasioId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('gimnasio')
        .doc(gimnasioId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final publicKey = data['publicKey'] as String;
      final accessToken = data['accessToken'] as String;
      return {'publicKey': publicKey, 'accessToken': accessToken};
    } else {
      throw Exception("Gimnasio no encontrado");
    }
  }

  Future<bool> actualizarMembresia(
      Map<String, dynamic> updatedMembresiaData) async {
    try {
      final String? membresiaId =
          updatedMembresiaData.remove('origenMembresia');
      if (membresiaId == null) {
        throw Exception('Missing "membresiaId" field in updatedMembresiaData');
      }
      FirebaseFirestore.instance
          .collection('membresia')
          .doc(membresiaId)
          .update(updatedMembresiaData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      print("Error updating document: ${e.message}");
      return false;
    } catch (e) {
      print("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }

  Future<bool> eliminarMembresia(String documentId) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('membresia').doc(documentId);
      await docRef.delete();
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      print("Error deleting document: ${e.message}");
      return false;
    } catch (e) {
      print("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }
}
