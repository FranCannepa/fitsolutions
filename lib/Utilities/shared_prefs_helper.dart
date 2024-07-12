//import 'dart:developer';

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final String _currentUser = 'userId';
  final String _emailKey = 'email';
  final String _isLogged = 'isLoggedIn';
  final String _userTipo = 'userTipo';
  final String _propietarioGym = 'propietarioGym';
  final String _asociadoId = 'asociadoId';
  final String _membresiaId = 'mebresiaId';

  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();

  factory SharedPrefsHelper() => _instance;

  SharedPrefsHelper._internal();

  Future<SharedPreferences> _getInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> esBasico() async {
    final String? userType = await getUserTipo();
    return userType == "Basico";
  }

  Future<bool> tieneSub() async {
    final String? tieneSub = await getSubscripcion();
    return tieneSub != null;
  }

  Future<bool> esPropietario() async {
    final String? userType = await getUserTipo();
    return userType == "Propietario";
  }

  Future<bool> esEntrenador() async {
    final String? userType = await getUserTipo();
    return userType == "Entrenador";
  }

  Future<void> setMembresia(String membresiaId) async {
    final prefs = await _getInstance();
    await prefs.setString(_membresiaId, membresiaId);
  }

  Future<String?> getMembresia() async {
    final prefs = await _getInstance();
    return prefs.getString(_membresiaId);
  }

  Future<void> setSubscripcion(String subId) async {
    final prefs = await _getInstance();
    await prefs.setString(_asociadoId, subId);
  }

  Future<void> setGymPropietario(String gymId) async {
    final prefs = await _getInstance();
    await prefs.setString(_propietarioGym, gymId);
  }

  Future<String?> getSubscripcion() async {
    final prefs = await _getInstance();
    return prefs.getString(_asociadoId);
  }

  Future<void> setLoggedIn(bool isLogged) async {
    final prefs = await _getInstance();
    await prefs.setBool(_isLogged, isLogged);
  }

  Future<bool> getLoggedIn() async {
    final prefs = await _getInstance();
    return prefs.getBool(_isLogged) ?? false;
  }

  Future<void> setUserTipo(String tipo) async {
    final prefs = await _getInstance();
    await prefs.setString(_userTipo, tipo);
  }

  Future<String?> getUserTipo() async {
    final prefs = await _getInstance();
    return prefs.getString(_userTipo);
  }

  Future<void> setUserId(String userId) async {
    final prefs = await _getInstance();
    await prefs.setString(_currentUser, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _getInstance();
    return prefs.getString(_currentUser);
  }

  Future<void> setEmail(String email) async {
    final prefs = await _getInstance();
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getEmail() async {
    final prefs = await _getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> clearAll() async {
    final prefs = await _getInstance();
    await prefs.clear();
  }

  Future<bool> hasKey(String key) async {
    final prefs = await _getInstance();
    return prefs.containsKey(key);
  }

  Future<bool> removeKey(String key) async {
    final prefs = await _getInstance();
    return await prefs.remove(key);
  }

  void initializeData() async {
    setLoggedIn(true);
    String? userEmail = await getEmail();
    if (userEmail != null) {
      final userData = await getUserData(userEmail);
      final userTipo = userData?['tipo'];
      setUserId(userData?['userId']);
      setEmail(userData?['email']);
      if (userTipo == "Basico") {
        await initializeBasico(userData);
      } else if (userTipo == "Propietario") {
        await initializePropietario(userData);
      } else if (userTipo == "Entrenador") {
        await initializeEntrenador(userData);
      }
    }
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
      return null;
    }
  }

  Future<String?> getTrainerInfo(String propietarioId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trainerInfo')
          .where('propietarioId', isEqualTo: propietarioId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        return docSnapshot.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
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
      data['userId'] = docSnapshot.id;
      return data;
    } else {
      return {};
    }
  }

  Future<void> initializeBasico(Map<String, dynamic>? userData) async {
    await setUserTipo("Basico");
    await setEmail(userData?['email']);
    setSubscripcion(userData?['asociadoId'] ?? '');
  }

  Future<void> initializePropietario(Map<String, dynamic>? userData) async {
    setUserTipo("Propietario");
    setEmail(userData?['email']);
    final gymId = await getGimnasioPropietario(userData?['userId']) ?? '';
    setSubscripcion(gymId);
  }

  Future<void> initializeEntrenador(Map<String, dynamic>? userData) async {
    setUserTipo("Entrenador");
    setEmail(userData?['email']);
    final trainerId = await getTrainerInfo(userData?['userId']) as String;
    setSubscripcion(trainerId);
  }
}
