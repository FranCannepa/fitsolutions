import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../Utilities/utilities.dart';

class UserProvider extends ChangeNotifier {
  // Shared preferences helper for storing and retrieving user data locally
  final SharedPrefsHelper prefs = SharedPrefsHelper();

  // Firebase Auth and Firestore instances
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Current user instance
  User? _user;

  // Flag to check if this is the user's first login
  bool _firstLogin = false;

  // Logger instance for logging events and errors
  final Logger log = Logger();

  // Constructor to initialize Firebase Auth and Firestore instances
  // Listens to authentication state changes to update the current user
  UserProvider({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      log.d('User authenticated: $isAuthenticated');
      notifyListeners();
    });
  }

  // Getters for user-related properties
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get firstLogin => _firstLogin;
  SharedPrefsHelper get pref => prefs;

  // Method to check if a user exists in the Firestore collection 'usuario'
  Future<Map<String, dynamic>?> checkUserExistence(User user) async {
    try {
      // Query Firestore for a user with the provided email
      final querySnapshot = await _firestore
          .collection('usuario')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      // If no user is found, return null
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      // Get the first document and its data
      final doc = querySnapshot.docs.first;
      final Map<String, dynamic> userData = doc.data();
      userData['docId'] = doc.id; // Add document ID to user data

      return userData;
    } catch (e) {
      log.d("Error checking user existence: $e");
      return null;
    }
  }

  // Method to sign in a user with email and password
  Future<void> signIn(String email, String password) async {
    try {
      // Sign in with Firebase Auth
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore
      QuerySnapshot querySnapshot = await _firestore
          .collection('usuario')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.size > 0) {

        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> docData = documentSnapshot.data() as Map<String, dynamic>;
        await prefs.setEmail(docData['email']);
        await prefs.setUserId(documentSnapshot.id);
        await prefs.setLoggedIn(true);
        _firstLogin = false; 
      } else {

        _firstLogin = true;
        await prefs.setEmail(email);
        await prefs.setLoggedIn(true);
      }
    } on FirebaseAuthException catch (e) {
      log.e('FirebaseAuthException in signIn: $e');
      rethrow; 
    } catch (e) {
      log.e('Exception in signIn: $e');
      rethrow;
    }
  }

  // Method to sign in a user with Google
  Future<User?> signInWithGoogle() async {
    try {
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithProvider(GoogleAuthProvider());
      return userCredential.user;
    } catch (e) {
      log.e('Exception in signInWithGoogle: $e');
      rethrow;
    }
  }

  // Method to sign up a new user with email and password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _firstLogin = true; // Mark as first login
      return userCred;
    } on FirebaseAuthException catch (e) {
      log.e('FirebaseAuthException in signUp: $e');
      throw Exception('Un usuario con ese email ya existe');
    } catch (e) {
      log.e('Exception in signUp: $e');
      rethrow;
    }
  }

  // Method to reset user password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log.e('FirebaseAuthException in resetPassword: $e');
      rethrow; // Rethrow the exception for further handling
    } catch (e) {
      log.e('Exception in resetPassword: $e');
      rethrow;
    }
  }

  // Method to sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut(); // Sign out from Firebase Auth
      await prefs.clearAll(); // Clear all stored preferences
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      log.e('Exception in signOut: $e');
      rethrow;
    }
  }
}
