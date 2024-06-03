import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class UserData extends ChangeNotifier {
  String nombreCompleto = '';
  String tipo = '';
  String userId = '';
  String fechaNacimiento = '';
  int altura = 0;
  double peso = 0;
  String email = '';
  String photoUrl = '';
  late String gimnasioId = '';
  late String calendarioId = '';
  late String membresiaId = '';
  String? gimnasioIdPropietario = '';

  final prefs = SharedPrefsHelper();
  void initializeData() async {
    final prefs = SharedPrefsHelper();
    Logger log = Logger();
    String? userEmail = await prefs.getEmail();
    if (userEmail != null) {
      final userData = await getUserData(userEmail);
      final userTipo = userData?['tipo'];
      if (userTipo == "Basico") {
        dataFormBasic(userData);
      } else if (userTipo == "Propietario") {
        dataFormPropietario(userData);
      } else {
        dataFormParticular(userData);
      }
    } else {
      log.d("EMPTY EMAIL!");
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      return data;
    } else {
      return {};
    }
  }

  bool esPropietarioGym() {
    return gimnasioIdPropietario != '';
  }

  bool esBasico() {
    return tipo == "Basico";
  }

  bool esPropietario() {
    return tipo == "Propietario";
  }

  bool esParticular() {
    return tipo == "Particular";
  }

  void updateCurrentGym(String gymId) {
    gimnasioId = gymId;
    notifyListeners();
  }

  void updateGymPropietario(String gymId) {}

  void updateNombreCompleto(String newNombreCompleto) {
    nombreCompleto = newNombreCompleto;
    notifyListeners();
  }

  void updateTipo(String newTipo) {
    tipo = newTipo;
    notifyListeners();
  }

  void updateDocId(String newDocId) {
    userId = newDocId;
    notifyListeners();
  }

  void updateFechaNacimiento(String newFechaNacimiento) {
    fechaNacimiento = newFechaNacimiento;
    notifyListeners();
  }

  void updateAltura(int newAltura) {
    altura = newAltura;
    notifyListeners();
  }

  void updatePeso(double newPeso) {
    peso = newPeso;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    email = newEmail;
    notifyListeners();
  }

  void dataFormBasic(Map<String, dynamic>? userData) async {
    String? docId = userData?['docId'];
    if (docId != null) {
      userId = docId;
    } else {
      userId = await prefs.getDocId() as String;
    }
    nombreCompleto = userData?['nombreCompleto'] ?? '';
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    gimnasioId = userData?['gimnasioId'] ?? '';
    tipo = "Basico";
    altura = userData?['altura'] ?? 0;
    peso = userData?['peso'] ?? 0;
    notifyListeners();
  }

  void dataFormPropietario(Map<String, dynamic>? userData) async {
    userId = userData?['docId'] ?? await prefs.getDocId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    gimnasioIdPropietario = await getGimnasioPropietario(userId);
    notifyListeners();
  }

  void dataFormParticular(Map<String, dynamic>? userData) async {
    userId = userData?['docId'] ?? await prefs.getDocId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    notifyListeners();
  }

  void firstLogin(User user) {
    if (user.email!.isNotEmpty) {
      final prefs = SharedPrefsHelper();
      email = user.email as String;
      photoUrl = user.photoURL!= null ? user.photoURL as String : '';
      prefs.setEmail(email);
    }
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic>? userData) {
    userId = userData?['docId'] ?? '';
    nombreCompleto = userData?['nombre_completo'] ?? '';
    tipo = userData?['tipo'] ?? '';
    notifyListeners();
  }

  Future<String?> getGimnasioPropietario(String propietarioId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: propietarioId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        return docSnapshot.id;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchActividades(DateTime fecha) async {
    try {
      final todayStart = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('gimnasioId', isEqualTo: gimnasioIdPropietario)
          .where('inicio', isGreaterThanOrEqualTo: todayStart)
          .where('fin', isLessThanOrEqualTo: todayEnd)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final fetchedActividades = querySnapshot.docs.map((doc) {
          final actividadData = doc.data();
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

//   Future<List<Map<String, dynamic>>> getActividadesSuigienteD(int page, int pageSize) async {
//   try {
//     final now = DateTime.now();
//     final startDate = now.subtract(Duration(days: (page - 1) * pageSize));
//     final endDate = startDate.add(Duration(days: pageSize));
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('actividad')
//         .where('gimnasioId', isEqualTo: gimnasioIdPropietario)
//         .where('inicio', isGreaterThanOrEqualTo: startDate)
//         .where('fin', isLessThanOrEqualTo: endDate)
//         .get();
//     if (querySnapshot.docs.isNotEmpty) {
//       final fetchedActividades = querySnapshot.docs.map((doc) {
//         // ... existing logic to convert doc data to Map
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
