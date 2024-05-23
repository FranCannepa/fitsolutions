import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:fitsolutions/components/CommonComponents/my_textfield.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/forgot_password_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginEmailScreen extends StatefulWidget {
  final UserProvider userProvider;
  const LoginEmailScreen({super.key, required this.userProvider});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

Future<Map<String, dynamic>?> _checkUserExistence(User user) async {
  Logger logger = Logger();
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('email', isEqualTo: user.email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final docId = querySnapshot.docs.first.id;
      final Map<String, dynamic> userData = doc.data();
      userData['docId'] = docId;
      return userData;
    } else {
      return null;
    }
  } catch (e) {
    logger.d("Error checking user existence: $e");
    return null;
  }
}

void _handleGoogleSignIn(BuildContext context) async {
  Logger logger = Logger();
  final userProvider = context.read<UserData>();
  final authProvider = context.read<UserProvider>();
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
    final User user = userCredential.user!;
    final Map<String, dynamic>? existingUserData =
        await _checkUserExistence(user);
    if (existingUserData != null) {
      userProvider.updateUserData(existingUserData);
    } else {
      if (user.email != null) {
        authProvider.firstTimeGoogle();
        userProvider.firstLogin(user.email as String);
      }
    }
  } on FirebaseAuthException catch (err) {
    logger.d(err.code);
    logger.d(err.message);
  }
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _formKeyLogin = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool passwordVisibility;
  IconData iconPassword = CupertinoIcons.eye_fill;
  String? _errorMsg;

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
              } catch (e) {
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
          SignInButton(Buttons.google, text: "Continuar con Google",
              onPressed: () {
            _handleGoogleSignIn(context);
          }),
        ],
      ),
    );
  }
}
