import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMsg;
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(title: const Text("RESTABLECER CONTRASEÑA"), backgroundColor: Colors.amber,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const Text(
                'Te enviaremos un email para restablecer tu contraseña',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Inter',
                  letterSpacing: 0,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 30),
              MyTextField(
                  key: const Key('email_key'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if(_formKey.currentState!.validate()){
                      await userProvider.resetPassword(_emailController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Se envio un email para restablecer su contraseña")),
                        );
                        Navigator.pop(context); // Return to login page
                    }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Error al enviar email de Reset")),
                      );
                    }
                  }
                },
                child: const Text("Restablecer contraseña"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
