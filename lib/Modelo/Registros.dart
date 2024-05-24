import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/NavigatorService.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';

class Registro {
  // Future<void> registrarUsuario(Map<String, dynamic> userData) async {
  //   final userProvider = context.read<UserData>();
  //   final prefs = SharedPrefsHelper();
  //   try {
  //     userData['email'] = userProvider.email;
  //     userData['profilePic'] = userProvider.photoUrl;
  //     userProvider.updateUserData(userData);
  //     final docRef =
  //         await FirebaseFirestore.instance.collection('usuario').add(userData);
  //     prefs.setLoggedIn(true);
  //     prefs.setDocId(docRef.id);
  //     NavigationService.instance.pushNamed("/home");
  //   } on FirebaseException catch (e) {
  //     print(e.code);
  //     print(e.message);
  //   }
  // }

  Future<void> registrarGimnasio(Map<String, dynamic> gymData) async {
    final prefs = SharedPrefsHelper();
    try {
      final docRef =
          await FirebaseFirestore.instance.collection('usuario').add(gymData);
      prefs.setLoggedIn(true);
      prefs.setDocId(docRef.id);
      NavigationService.instance.pushNamed("/home");
    } on FirebaseException catch (e) {
      print(e.code);
      print(e.message);
    }
  }
}
