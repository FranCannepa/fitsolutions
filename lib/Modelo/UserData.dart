import 'dart:ffi';

import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String nombre_completo = '';
  String tipo = '';
  String docId = '';
  String fechaNacimiento = '';
  double altura = 0;
  double peso = 0;
  String email = '';

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

  void updateAltura(double newAltura) {
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
    altura = userData?['altura'] ?? '';
    peso = userData?['peso'] ?? '';
    notifyListeners();
  }

  void firstLogin(String email) {
    if (email.isNotEmpty) {
      this.email = email;
    }
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic>? userData) {
    docId = userData?['docId'] ?? '';
    nombre_completo = userData?['nombre_completo'] ?? '';
    tipo = userData?['tipo'] ?? '';
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    altura = userData?['altura'];
    peso = userData?['peso'];
    notifyListeners();
  }
}
