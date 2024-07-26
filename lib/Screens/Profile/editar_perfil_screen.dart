import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditarPerfilScreen extends StatefulWidget {
  //late Map<String, dynamic> newUserData;

  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _birthdayController = TextEditingController();
  late Map<String, dynamic> userData = {};
  Future<void> submitPropietarioInfo() async {}

  @override
  Widget build(BuildContext context) {
    final userData = context.read<UserData>();
    return SafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const ScreenTitle(title: "Mi perfil (editar)"),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedInputField(
                        labelText: 'Nombre Completo',
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su nombre completo';
                          }
                          return null;
                        },
                      ),
                      // Conditional fields based on user type
                      if (userData.esBasico()) ...[
                        RoundedInputField(
                          labelText: 'Altura',
                          controller: _weightController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su altura';
                            }
                            return null;
                          },
                        ),
                        RoundedInputField(
                          labelText: 'Peso',
                          controller: _weightController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su peso';
                            }
                            return null;
                          },
                        ),
                        RoundedInputField(
                          labelText: 'Cumpleaños',
                          controller: _birthdayController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su cumpleaños';
                            }
                            return null;
                          },
                        ),
                      ],
      
                      if (userData.esPropietario()) ...[],
                      SubmitButton(
                        text: "Guardar Cambios",
                        onPressed: submitPropietarioInfo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //),
        ),
      ),
    );
  }
}
