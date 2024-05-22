import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:fitsolutions/Utilities/navigator_service.dart';
import 'package:fitsolutions/components/CommonComponents/custom_textfield.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool _validatePassword(String password){
  return true;
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
        final Map<String, dynamic> userData =
            doc.data();
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
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      final User user = userCredential.user!;
      final Map<String, dynamic>? existingUserData =
          await _checkUserExistence(user);
      if (existingUserData != null) {
        userProvider.updateUserData(existingUserData);
        NavigationService.instance.pushNamed("/home");
      } else {
        if (user.email != null) {
          userProvider.firstLogin(user.email as String);
          NavigationService.instance.pushNamed("/registro");
        }
      }
    } on FirebaseAuthException catch (err) {
      logger.d(err.code);
      logger.d(err.message);
    }
  }


class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  late bool passwordVisibility;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    passwordVisibility = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: SafeArea(
          top: true,
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                flex: 8,
                child: Container(
                    width: 100,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    alignment: const AlignmentDirectional(0, -1),
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 45, 0, 0),
                          child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              alignment: const AlignmentDirectional(-1, 0),
                              child: const Align(
                                  alignment: AlignmentDirectional(-1, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 0, 0),
                                        child: Text(
                                          'FitSolutions',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: Color(0xFF101213),
                                            fontSize: 24,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))),
                        ),
                        Container(
                          width: double.infinity,
                          height: 700,
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Column(
                              children: [
                                Align(
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    labelColor: const Color(0xFF101213),
                                    unselectedLabelColor:
                                        const Color(0xFF57636C),
                                    labelPadding: const EdgeInsets.all(16),
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF101213),
                                      fontSize: 36,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF101213),
                                      fontSize: 36,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    indicatorColor: const Color(0xFF4B39EF),
                                    indicatorWeight: 4,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 12, 16, 12),
                                    tabs: const [
                                      Tab(
                                        text: 'Iniciar sesion',
                                      ),
                                      Tab(
                                        text: 'Registrar',
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            CustomTextfield(
                                              labelText: 'Email',
                                              inputControl: _emailController,
                                              obscureText: false,
                                              child: null,
                                            ),
                                            const SizedBox(height: 30),
                                            CustomTextfield(
                                              labelText: 'Contraseña',
                                              inputControl: _passwordController,
                                              obscureText: !passwordVisibility,
                                              child: InkWell(
                                                onTap: () => setState(
                                                  () => passwordVisibility =
                                                      !passwordVisibility,
                                                ),
                                                focusNode: FocusNode(
                                                    skipTraversal: true),
                                                child: Icon(
                                                  passwordVisibility
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color:
                                                      const Color(0xFF57636C),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 40),
                                            SubmitButton(
                                              text: 'Iniciar Sesion',
                                              onPressed: () async {
                                                try {
                                                  await userProvider.signIn(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Failed to sign in")),
                                                  );
                                                }
                                              },
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));},
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0, 24, 0, 24),
                                                    child: RichText(
                                                        textScaler:
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaler,
                                                        text: const TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  'Olvidaste tu contraseña?',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                letterSpacing:
                                                                    0,
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SignInButton(Buttons.google,
                                                text: "Continuar con Google",
                                                onPressed: () {
                                                  _handleGoogleSignIn(context);
                                                }),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            CustomTextfield(
                                              labelText: 'Email',
                                              inputControl: _emailController,
                                              obscureText: false,
                                              child: null,
                                            ),
                                            CustomTextfield(
                                              labelText: 'Contraseña',
                                              inputControl: _passwordController,
                                              obscureText: !passwordVisibility,
                                              child: InkWell(
                                                onTap: () => setState(
                                                  () => passwordVisibility =
                                                      !passwordVisibility,
                                                ),
                                                focusNode: FocusNode(
                                                    skipTraversal: true),
                                                child: Icon(
                                                  passwordVisibility
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color:
                                                      const Color(0xFF57636C),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            CustomTextfield(
                                              labelText: 'Confirmar contraseña',
                                              inputControl: _passwordController,
                                              obscureText: !passwordVisibility,
                                              child: InkWell(
                                                onTap: () => setState(
                                                  () => passwordVisibility =
                                                      !passwordVisibility,
                                                ),
                                                focusNode: FocusNode(
                                                    skipTraversal: true),
                                                child: Icon(
                                                  passwordVisibility
                                                      ? Icons
                                                          .visibility_outlined
                                                      : Icons
                                                          .visibility_off_outlined,
                                                  color:
                                                      const Color(0xFF57636C),
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            SubmitButton(
                                              text: 'Registrarme',
                                              onPressed: () async {
                                                try {
                                                  await userProvider.signUp(
                                                    _emailController.text,
                                                    _passwordController.text,
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            "Failed to sign in")),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ))))
          ])),
    );
  }
}
