import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/user_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Logger log = Logger();
  Future<Map<String, dynamic>?> _checkUserExistence(User user) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuario')
          .where('email', isEqualTo: user.email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final docId = querySnapshot.docs.first.id;
        final Map<String, dynamic> userData =
            doc.data();
        userData['docId'] = docId;
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error checking user existence: $e");
      return null;
    }
  }

  void _handleGoogleSignIn() async {
    final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    Logger log = Logger();
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      final User user = userCredential.user!;
      final Map<String, dynamic>? existingUserData =
          await _checkUserExistence(user);
      if (existingUserData != null) {
        userProvider.updateUserData(existingUserData);
        prefs.setEmail(existingUserData['email']);
        prefs.setDocId(existingUserData['docId']);
        prefs.setLoggedIn(true);
        NavigationService.instance.pushNamed("/home");
      } else {
        if (user.email != null) {
          userProvider.firstLogin(user);
          NavigationService.instance.pushNamed("/registro");
        }
      }
    } on FirebaseAuthException catch (err) {
      log.d(err.code);
      log.d(err.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
                  ),
                ),

                //colocar logo applicacion
                child: const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 32.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SignInButton(
                Buttons.google,
                text: "Continuar con Google",
                onPressed: () {
                  _handleGoogleSignIn();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
