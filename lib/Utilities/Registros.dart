import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';

class Registro {
  Future<void> registrarGimnasio(Map<String, dynamic> gymData) async {
    print(gymData);
    final prefs = SharedPrefsHelper();
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('gimnasio').add(gymData);
      prefs.setLoggedIn(true);
      prefs.setDocId(docRef.id);
    } on FirebaseException catch (e) {
      print(e.code);
      print(e.message);
    }
  }
}
