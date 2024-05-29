import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utilities/utilities.dart';

class UserProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseAuth _firebaseAuth;
  final userCollection = FirebaseFirestore.instance.collection('usuario');
  User? _user;
  bool _firstLogin = false;
  UserProvider({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      log.d('Im here $isAuthenticated');
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get firstLogin => _firstLogin;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final prefs = SharedPrefsHelper();
      QuerySnapshot querySnapshot =
          await userCollection.where('email', isEqualTo: email).get();
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      final docData = documentSnapshot.data() as Map<String, dynamic>;
      prefs.setEmail(docData['email']);
      prefs.setDocId(documentSnapshot.id);
      prefs.setLoggedIn(true);
    } on FirebaseAuthException catch (e) {
      log.e(e);
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _firstLogin = true;
      
      return userCred;
    } on FirebaseAuthException catch (e) {
      log.e(e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log.e(e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log.t(e);
      rethrow;
    }
  }

  Future<void> registerCompleted() async {
    _firstLogin = false;
    notifyListeners();
  }

  //TODO
  Future<void> firstTimeGoogle() async {
    _firstLogin = true;
    notifyListeners();
  }
}
