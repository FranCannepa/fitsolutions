import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../Utilities/utilities.dart';

class UserProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  User? _user;
  bool _firstLogin = false;
  Logger log = Logger();

  //UserProvider({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  UserProvider({FirebaseAuth? firebaseAuth,FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance, _firestore = firestore ?? FirebaseFirestore.instance{
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      log.d('USUARIO AUTHENTICATED $isAuthenticated');
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get firstLogin => _firstLogin;
  SharedPrefsHelper get pref => prefs;

  Future<void> signIn(String email, String password) async {
    try {
      // Sign in with Firebase
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      // Fetch user data from Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('usuario').where('email', isEqualTo: email).limit(1).get();
      if(querySnapshot.size > 0){
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> docData =
            documentSnapshot.data() as Map<String, dynamic>;
        // Store user data in SharedPreferences
        await prefs.setEmail(docData['email']);
        await prefs.setDocId(documentSnapshot.id);
        await prefs.setLoggedIn(true);
      }
      else{
        _firstLogin = true;
        await prefs.setEmail(email);
        await prefs.setLoggedIn(true);
      }
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
      log.d('EXCEPTO $e');
      rethrow;
    } catch(e){
      log.d('EXCEPTO $e');
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
      await prefs.clearAll();
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      log.t(e);
      rethrow;
    }
  }
}
