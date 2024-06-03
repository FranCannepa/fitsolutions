import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:flutter/material.dart';

class PropietarioForm extends StatefulWidget {
  final Function(Map<String, dynamic>) registerFunction;
  const PropietarioForm({super.key, required this.registerFunction});

  @override
  State<PropietarioForm> createState() => _PropietarioFormState();
}

class _PropietarioFormState extends State<PropietarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  late Map<String, dynamic> userData = {};

  Map<String, dynamic> _collectUserData() {
    final nombreCompleto = _fullNameController.text;
    return {'nombreCompleto': nombreCompleto, 'tipo': "Propietario"};
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          const Text(
            'Formulario de Usuario Propietario',
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
