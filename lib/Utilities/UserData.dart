import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String nombre_completo = '';
  String tipo = '';
  String docId = '';
  String fechaNacimiento = '';
  int altura = 0;
  double peso = 0;
  String email = '';
  String photoUrl = '';
  late String gimnasioId = '';
  late String calendarioId = '';

  void updateNombreCompleto(String newNombreCompleto) {
    nombre_completo = newNombreCompleto;
    notifyListeners();
  }

  

  void updateTipo(String newTipo) {
    tipo = newTipo;
    notifyListeners();
  }

  void updateDocId(String newDocId) {
    docId = newDocId;
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

  void dataFormBasic(Map<String, dynamic>? userData) {
    nombre_completo = userData?['nombre_completo'];
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    tipo = 'Basico';
    altura = userData?['altura'] ?? 0;
    peso = userData?['peso'] ?? 0;
    notifyListeners();
  }

  void firstLogin(User user) {
    if (user.email!.isNotEmpty) {
      email = user.email as String;
      photoUrl = user.photoURL as String;
    }
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic>? userData) {
    docId = userData?['docId'] ?? '';
    nombre_completo = userData?['nombre_completo'] ?? '';
    tipo = userData?['tipo'] ?? '';
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    altura = userData?['altura'] ?? 0;
    peso = userData?['peso'] ?? 0;
    notifyListeners();
  }
}

class userDataPropietario extends UserData {
  //docId
  //nombre_completo
  //email
  //gimnasio
  //membresia
}

class userDataParticular extends UserData {}
