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
        child: Column(children: [
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
              text: "Continuar",
              onPressed: () {
                userData = _collectUserData();
                widget.registerFunction(userData);
              }),
        ]));
  }
}
