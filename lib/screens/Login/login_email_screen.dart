import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Components/CommonComponents/image_logo.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/user_data.dart';
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

  Future<void> _initializeData(
      UserData userDataProvider, UserProvider auth) async {
    await SharedPrefsHelper().initializeData();
    await userDataProvider.initializeData();
  }

  void _handleGoogleSignIn() async {
    final userProvider = context.read<UserData>();
    final authProvider = context.read<UserProvider>();

    final prefs = SharedPrefsHelper();
    Logger log = Logger();

    try {
      final User? user = await authProvider.signInWithGoogle();

      if (user == null) {
        log.d("User is null after sign-in with Google.");
        return;
      }

      // Check if the user exists
      final Map<String, dynamic>? existingUserData =
          await authProvider.checkUserExistence(user);
      if (existingUserData != null) {
        // Update user data in provider and SharedPreferences
        userProvider.updateUserData(existingUserData);
        await prefs.setEmail(existingUserData['email']);
        await prefs.setUserId(existingUserData['docId']);
        await prefs.setLoggedIn(true);

        // Navigate to home
        if (mounted) {
          await _initializeData(
              context.read<UserData>(), context.read<UserProvider>());
        }
        NavigationService.instance.pushNamed("/home");
      } else {
        if (user.email != null) {
          userProvider.firstLogin(user);
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
    return SingleChildScrollView(
      child: Form(
          key: _formKeyLogin,
          child: Column(children: [
            const LogoWidget(
              assetPath: "assets/media/main_logo.png",
              height: 200,
              width: 200,
            ),
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
                  await widget.userProvider.signIn(
                    _emailController.text,
                    _passwordController.text,
                  );

                  if (widget.userProvider.firstLogin && context.mounted) {
                    NavigationService.instance.pushNamed('/registro');
                  } else if (context.mounted) {
                    await _initializeData(
                        context.read<UserData>(), context.read<UserProvider>());
                    NavigationService.instance.pushNamed("/home");
                  }
                } catch (e) {
                  log.d(e);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Column(
                        children: [
                          Text(
                              "Credenciales erroneas, error al intentar ingresar"),
                          Text("Revisar sus credenciales"),
                        ],
                      )),
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
              width: double.infinity, // Adjust the width as needed
              child: SignInButton(Buttons.google, text: "Iniciar con Google",
                  onPressed: () {
                _handleGoogleSignIn();
              }),
            ),
            Container(
              margin: const EdgeInsets.only(top: 90.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Registro de Usuario",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}
