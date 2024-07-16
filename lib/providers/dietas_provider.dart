import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DietaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  final query = FirebaseFirestore.instance;
  Logger log = Logger();

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
          dietaData['dietaId'] = dietaId;
          final dieta = Dieta.fromDocument(dietaData);
          return dieta;
        } else {
          Logger().d("Dieta document not found for user ID: $userId");
          return null;
        }
      } else {
         Logger().d("User data does not contain 'dietaId' key");
        return null;
      }
    } else {
       Logger().d("User document not found for user ID: $userId");
      return null;
    }
  }

  Future<List<Dieta>> getDietas() async {
    final String? origenMembresia = await prefs.getSubscripcion();
    try {
      final List<Dieta> dietas = [];
      if (origenMembresia != null) {
        final dietQuery = query
            .collection('dieta')
            .where('origenDieta', isEqualTo: origenMembresia);
        final querySnapshot = await dietQuery.get();
        for (var doc in querySnapshot.docs) {
          final dietaData = doc.data();
          final dieta = Dieta.fromDocument({
            ...dietaData,
            "dietaId": doc.id,
          });
          dietas.add(dieta);
        }
      }
      return dietas;
    } catch (error) {
      Logger().d("Error fetching dietas: $error");
      return [];
    }
  }

  Future<bool> agregarDieta(Map<String, dynamic> dietaData) async {
    try {
      await query.collection('dieta').add(dietaData);
      notifyListeners();
      return true;
    } catch (e) {
      log.d(e.toString());
      return false;
    }
  }

  Future<bool> actualizarDieta(Map<String, dynamic> dietaData, String dietaId) async {
    try {
      await query.collection('dieta').doc(dietaId).update(dietaData);
      notifyListeners();
      return true;
    } catch (e) {
      log.d(e.toString());
      return false;
    }
  }

  Future<bool> asignarDieta(String dietaId, String clienteId) async {
    try {
      final userDocRef =
          FirebaseFirestore.instance.collection('usuario').doc(clienteId);

      final updateData = {'dietaId': dietaId};
      await userDocRef.update(updateData);

      return true;
    } catch (e) {
      log.d(e.toString());
      return false;
    }
  }

  Future<bool> eliminarDieta(String documentId) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    try {
      final docRef = db.collection('dieta').doc(documentId);

      batch.delete(docRef);

      final usuariosQuery =
          db.collection('usuario').where('dietaId', isEqualTo: documentId);
      await db.runTransaction((transaction) async {
        final snapshot = await usuariosQuery.get();
        for (final doc in snapshot.docs) {
          transaction.update(doc.reference, {'dietaId': FieldValue.delete()});
        }
      });
      await batch.commit();
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      Logger().d("Error deleting document: ${e.message}");
      return false;
    } catch (e) {
      Logger().d("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }
}
