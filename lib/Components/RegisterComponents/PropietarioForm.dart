import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/input_roundFields.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Components/RegisterComponents/GimnasioForm.dart';
import 'package:fitsolutions/Utilities/Registros.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';
import 'package:flutter/material.dart';

class PropietarioForm extends StatefulWidget {
  final Function(Map<String, dynamic>) registerFunction;
  const PropietarioForm({super.key, required this.registerFunction});

  @override
  _PropietarioFormState createState() => _PropietarioFormState();
}

class _PropietarioFormState extends State<PropietarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  late Map<String, dynamic> userData = {};
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _collectUserData() {
      final nombreCompleto = _fullNameController.text;
      return {'nombreCompleto': nombreCompleto, 'tipo': "Propietario"};
    }

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
