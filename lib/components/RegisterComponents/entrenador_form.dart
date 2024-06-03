import 'package:fitsolutions/components/components.dart';
import 'package:flutter/material.dart';

class EntrenadorForm extends StatefulWidget {
  final Function(Map<String, dynamic>) registerFunction;
  const EntrenadorForm({super.key, required this.registerFunction});

  @override
  State<EntrenadorForm> createState() => _EntrenadorFormState();
}

class _EntrenadorFormState extends State<EntrenadorForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  late Map<String, dynamic> userData = {};

  Map<String, dynamic> _collectUserData() {
    final nombreCompleto = _fullNameController.text;
    return {'nombreCompleto': nombreCompleto, 'tipo': "Entrenador"};
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          const Text(
            'Formulario de Usuario Entrenador',
            style: TextStyle(
              fontFamily: 'Sora',
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 40,
            ),
          ),
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
          SubmitButton(
              text: "Ingresar",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final userData = _collectUserData();
                  widget.registerFunction(userData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Errores en el Formulario")),
                  );
                }
              })
        ]));
  }
}
