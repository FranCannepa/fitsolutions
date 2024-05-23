import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  final String _docIdKey = 'docId';
  final String _emailKey = 'email';
  final String _isLogged = 'isLoggedIn';
  final String _currentGymId = '_currentGymId';

  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();

  factory SharedPrefsHelper() => _instance;

  SharedPrefsHelper._internal();

  Future<SharedPreferences> _getInstance() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setLoggedIn(bool isLogged) async {
    final prefs = await _getInstance();
    await prefs.setBool(_isLogged, isLogged);
  }

  Future<bool> getLoggedIn() async {
    final prefs = await _getInstance();
    return prefs.getBool(_isLogged) ?? false;
  }

  Future<void> setDocId(String docId) async {
    final prefs = await _getInstance();
    await prefs.setString(_docIdKey, docId);
  }

  Future<String?> getDocId() async {
    final prefs = await _getInstance();
    return prefs.getString(_docIdKey);
  }

  Future<String?> getCurrentGymId() async {
    final prefs = await _getInstance();
    return prefs.getString(_currentGymId);
  }

  Future<void> setCurrentGymId(String gymId) async {
    final prefs = await _getInstance();
    await prefs.setString(_currentGymId, gymId);
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
}
