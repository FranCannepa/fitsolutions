import 'dart:developer';

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
  String gimnasioId = '';
  late String calendarioId = '';
  late String membresiaId = '';
  late String entrenadorId = '';
  String? gimnasioIdPropietario = '';

  final prefs = SharedPrefsHelper();
  Logger log = Logger();

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

  Future<String?> getUserId() async {
    final String? userId = await SharedPrefsHelper().getUserId();
    return userId;
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      data['userId'] = docSnapshot.id;
      return data;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final String? userId = await SharedPrefsHelper().getUserId();
    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuario').doc(userId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error getting user: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMembresias(
      String origenMembresia) async {
    final collection = FirebaseFirestore.instance.collection('membresia');
    final querySnapshot = await collection
        .where('origenMembresia', isEqualTo: origenMembresia)
        .get();
    final membersias = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    return membersias;
  }

  Future<Map<String, dynamic>?> getMembresia() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('membresia')
        .doc(membresiaId)
        .get();

    if (querySnapshot.exists) {
      final data = querySnapshot.data();
      return data;
    } else {
      return null;
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

  void updateuserId(String newuserId) {
    userId = newuserId;
    notifyListeners();
  }

  Future<bool?> tieneSub() async {
    final bool? sub = await prefs.tieneSub();
    return sub;
  }

  bool tieneMembresia() {
    return membresiaId != '';
  }

  void updateFechaNacimiento(String newFechaNacimiento) {
    fechaNacimiento = newFechaNacimiento;
    notifyListeners();
  }

  void dataFormBasic(Map<String, dynamic>? userData) async {
    String? userId = userData?['userId'];
    if (userId != null) {
      userId = userId;
    } else {
      userId = await prefs.getUserId() as String;
    }
    nombreCompleto = userData?['nombreCompleto'] ?? '';
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    gimnasioId = userData?['gimnasioSub'] ?? '';
    entrenadorId = userData?['entrenadorSub'] ?? '';
    membresiaId = userData?['membresiaId'] ?? '';
    tipo = "Basico";
    altura = userData?['altura'] ?? 0;
    peso = userData?['peso'] ?? 0;
    notifyListeners();
  }

  void dataFormPropietario(Map<String, dynamic>? userData) async {
    userId = userData?['userId'] ?? await prefs.getUserId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    gimnasioIdPropietario = await getGimnasioPropietario(userId);
    notifyListeners();
  }

  void dataFormParticular(Map<String, dynamic>? userData) async {
    userId = userData?['userId'] ?? await prefs.getUserId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    notifyListeners();
  }

  void firstLogin(User user) {
    if (user.email!.isNotEmpty) {
      final prefs = SharedPrefsHelper();
      email = user.email as String;
      photoUrl = user.photoURL != null ? user.photoURL as String : '';
      prefs.setEmail(email);
    }
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic>? userData) {
    userId = userData?['userId'] ?? '';
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

  Future<List<Map<String, dynamic>>> fetchActividadesGimnasio(
      DateTime fecha) async {
    final gymId = esBasico() ? gimnasioId : gimnasioIdPropietario;
    final todayStart = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
    final todayEnd = todayStart.add(const Duration(days: 1));
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: gymId)
          .where('inicio',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('fin', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
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

  Future<List<Map<String, dynamic>>> fetchActividadesEntrenador(
      DateTime fecha, String ownerActividades) async {
    try {
      final todayStart = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: ownerActividades)
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
}
