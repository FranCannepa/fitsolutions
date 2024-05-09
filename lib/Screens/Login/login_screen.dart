import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<Map<String, dynamic>> _checkUserExistence(User user) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('email', isEqualTo: user.email)
        .get();
    final doc = querySnapshot.docs.first;
    final docId = querySnapshot.docs.first.id;
    final Map<String, dynamic> userData = doc.data();
    userData['docId'] = docId;
    return userData;
  }

  @override
  void initState() {
    super.initState();
  }

  void _handleGoogleSignIn() async {
    try {
      //final userDataProvider = Provider.of<UserData>(context);
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      final User user = userCredential.user!;
      final Map<String, dynamic> userData =
          await _checkUserExistence(user); // Remove const
      if (userData != null) {
        print("HAY USUARIO");
        print(userData);
        //Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("NO HAY USUARIO");
        // Navigator.pushReplacementNamed(context, '/register');
      }
    } on FirebaseAuthException catch (err) {
      print(err.code);
      print(err.message);
      // Handle sign-in errors (e.g., show error message to user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SizedBox(
                height: 100,
                child: Column(
                  children: [
                    SignInButton(
                      Buttons.google,
                      text: "Sign up with Google",
                      onPressed: () {
                        _handleGoogleSignIn();
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/registro');
                      },
                      child: const Text('Create Account'),
                    ),
                  ],
                ))));
  }
}
