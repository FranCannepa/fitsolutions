import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:logger/logger.dart';

class Registro {
  Logger log = Logger();
  
  Future<void> registrarGimnasio(Map<String, dynamic> gymData) async {
    log.d(gymData);
    final prefs = SharedPrefsHelper();
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('gimnasio').add(gymData);
      prefs.setLoggedIn(true);
      prefs.setDocId(docRef.id);
    } on FirebaseException catch (e) {
      log.d(e.code);
      log.d(e.message);
    }
  }
}
