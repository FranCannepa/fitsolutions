import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/forgot_password_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../Utilities/utilities.dart';

class LoginEmailScreen extends StatefulWidget {
  final UserProvider userProvider;
  const LoginEmailScreen({super.key, required this.userProvider});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _formKeyLogin = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late bool passwordVisibility;

  IconData iconPassword = CupertinoIcons.eye_fill;
  String? _errorMsg;
  Logger log = Logger();

  Future<Map<String, dynamic>?> _checkUserExistence(User user) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuario')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final Map<String, dynamic> userData = doc.data();
      userData['docId'] = doc.id;

      return userData;
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
      // Sign in with Google
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      final User? user = userCredential.user;

      if (user == null) {
        log.d("User is null after sign-in with Google.");
        return;
      }

      // Check if the user exists
      final Map<String, dynamic>? existingUserData =
          await _checkUserExistence(user);
      if (existingUserData != null) {
        // Update user data in provider and SharedPreferences
        userProvider.updateUserData(existingUserData);
        await prefs.setEmail(existingUserData['email']);
        await prefs.setDocId(existingUserData['docId']);
        await prefs.setLoggedIn(true);

        // Navigate to home
        NavigationService.instance.pushNamed("/home");
      } else {
        if (user.email != null) {
          userProvider.firstLogin(user);
          // Navigate to registration
          NavigationService.instance.pushNamed("/registro");
        }
      }
    } on FirebaseAuthException catch (err) {
      log.d("FirebaseAuthException: ${err.code} - ${err.message}");
    } catch (err) {
      log.d("Error during Google sign-in: $err");
    }
  }

  @override
  void initState() {
    passwordVisibility = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeyLogin,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(height: 30),
          MyTextField(
              controller: _emailController,
              hintText: 'Email',
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              errorMsg: _errorMsg,
              prefixIcon: const Icon(CupertinoIcons.mail_solid),
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Porfavor llenar este campo';
                } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$')
                    .hasMatch(val)) {
                  return 'Porfavor ingresar un email valido';
                }
                return null;
              }),
          const SizedBox(height: 30),
          MyTextField(
            controller: _passwordController,
            hintText: 'Contraseña',
            obscureText: !passwordVisibility,
            keyboardType: TextInputType.visiblePassword,
            prefixIcon: const Icon(CupertinoIcons.lock_fill),
            errorMsg: _errorMsg,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Porfavor llenar este campo';
              }
              return null;
            },
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  passwordVisibility = !passwordVisibility;
                  if (passwordVisibility) {
                    iconPassword = CupertinoIcons.eye_slash_fill;
                  } else {
                    iconPassword = CupertinoIcons.eye_fill;
                  }
                });
              },
              icon: Icon(iconPassword),
            ),
          ),
          const SizedBox(height: 40),
          SubmitButton(
            text: 'Iniciar Sesion',
            onPressed: () async {
              try {
                /**/
                await widget.userProvider.signIn(
                  _emailController.text,
                  _passwordController.text,
                );
                if(widget.userProvider.firstLogin && context.mounted){
                  NavigationService.instance.pushNamed('/registro');
                }else{
                NavigationService.instance.pushNamed("/home");
                }
              } catch (e) {
                log.d(e);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Error al intentar Iniciar Sesion")),
                  );
                }
              }
            },
          ),
          InkWell(
            key: const Key('Restablecer'),
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen()));
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
                  child: RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'RESTABLECER CONTRASEÑA',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          
          SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.4, // 40% of screen width
              child: SignInButton(Buttons.google, text: "Continuar con Google",
                  onPressed: () {
                _handleGoogleSignIn();
              }),
          ),
        ],
      ),
    );
  }
}
