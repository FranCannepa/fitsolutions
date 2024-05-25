//import 'package:fitsolutions/Modelo/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart';

class RegisterEmailScreen extends StatefulWidget {
  final UserProvider userProvider;
  const RegisterEmailScreen({super.key, required this.userProvider});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _formKeyRegister = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  late bool passwordVisibility;
  late bool confirmPasswordVisibility;
  String? _errorMsg;

  IconData iconPassword = CupertinoIcons.eye_fill;
  IconData iconConfirmPassword = CupertinoIcons.eye_fill;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  String? passwordRegisterVerification(String? val) {
    if (val!.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        containsUpperCase = true;
      });
    } else {
      setState(() {
        containsUpperCase = false;
      });
    }
    if (val.contains(RegExp(r'[a-z]'))) {
      setState(() {
        containsLowerCase = true;
      });
    } else {
      setState(() {
        containsLowerCase = false;
      });
    }
    if (val.contains(RegExp(r'[0-9]'))) {
      setState(() {
        containsNumber = true;
      });
    } else {
      setState(() {
        containsNumber = false;
      });
    }
    if (val.contains(RegExp(r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
      setState(() {
        containsSpecialChar = true;
      });
    } else {
      setState(() {
        containsSpecialChar = false;
      });
    }
    if (val.length >= 8) {
      setState(() {
        contains8Length = true;
      });
    } else {
      setState(() {
        contains8Length = false;
      });
    }
    return null;
  }

  void snackBarMessage(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
  @override
  void initState() {
    passwordVisibility = false;
    confirmPasswordVisibility = false;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeyRegister,
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
                  return 'Please fill in this field';
                } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$')
                    .hasMatch(val)) {
                  return 'Please enter a valid email';
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
            onChanged: passwordRegisterVerification,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Porfavor completa este campo';
              } else if (!RegExp(
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                  .hasMatch(val)) {
                return 'Porfavor ingresa una contraseña valida';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Requerimientos'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚈  1 Caracter mayusucla",
                    style: TextStyle(
                        color: containsUpperCase
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    "⚈  1 Caracter minuscula",
                    style: TextStyle(
                        color: containsLowerCase
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    "⚈  1 Numero",
                    style: TextStyle(
                        color: containsNumber
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚈  1 Caracter especial",
                    style: TextStyle(
                        color: containsSpecialChar
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    "⚈  Minimo 8 caracteres",
                    style: TextStyle(
                        color: contains8Length
                            ? Colors.green
                            : Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          MyTextField(
            controller: _confirmController,
            hintText: 'Confirmar contraseña',
            obscureText: !confirmPasswordVisibility,
            keyboardType: TextInputType.visiblePassword,
            prefixIcon: const Icon(CupertinoIcons.lock_fill),
            errorMsg: _errorMsg,
            validator: (val) {
              if (val!.isEmpty) {
                return 'Porfavor completa este campo';
              } else if (!RegExp(
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$')
                  .hasMatch(val)) {
                return 'Porfavor ingresa una contraseña valida';
              }
              return null;
            },
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  confirmPasswordVisibility = !confirmPasswordVisibility;
                  if (confirmPasswordVisibility) {
                    iconConfirmPassword = CupertinoIcons.eye_slash_fill;
                  } else {
                    iconConfirmPassword = CupertinoIcons.eye_fill;
                  }
                });
              },
              icon: Icon(iconConfirmPassword),
            ),
          ),
          const SizedBox(height: 20),
          SubmitButton(
            text: 'Registrarme',
            onPressed: () async {
              try {
                bool valid = _formKeyRegister.currentState!.validate();
                if (valid && _passwordController.text == _confirmController.text) {
                  UserCredential userCred = await widget.userProvider.signUp(
                    _emailController.text,
                    _passwordController.text,
                  );

                  if(context.mounted){
                    final userDataProvider = context.read<UserData>();
                    userDataProvider.firstLogin(userCred.user!);
                    NavigationService.instance.pushNamed("/registro");
                  }

                } else if(!valid) {
                  snackBarMessage(context, "El formulario tiene errores");
                } else{
                  snackBarMessage(context, "Las contraseñas no coiniciden");
                }
              } catch (e) {
                //It's being handle inside the function
                // ignore: use_build_context_synchronously
                snackBarMessage(context, 'Error al registrarse $e ');
              }
            },
          ),
        ],
      ),
    );
  }
}
