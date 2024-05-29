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

  void dataFormPropietario(Map<String, dynamic>? userData) async{
    userId = userData?['docId'] ?? await prefs.getDocId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    notifyListeners();
  }

  void dataFormParticular(Map<String, dynamic>? userData) async{
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
}
