
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:flutter/material.dart';

class BasicoForm extends StatefulWidget {
  final Function(Map<String, dynamic>) registerFunction;

  const BasicoForm({super.key, required this.registerFunction});

  @override
  State<BasicoForm> createState() => _BasicoFormState();
}

class _BasicoFormState extends State<BasicoForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  Map<String, dynamic> collectUserData() {
      final pesoString = _weightController.text.replaceAll(",", ".");
      final nombreCompleto = _fullNameController.text;
      final fechaNacimiento = _dateOfBirthController.text;
      final peso = double.tryParse(pesoString);
      final altura = int.tryParse(_heightController.text);
      return {
        'nombreCompleto': nombreCompleto,
        'fechaNacimiento': fechaNacimiento,
        'peso': peso,
        'altura': altura,
        'tipo': "Basico"
      };
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
          RoundedInputField(
            labelText: 'Fecha de Nacimiento (YYYY-MM-DD)',
            controller: _dateOfBirthController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su fecha de nacimiento';
              }
              RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
              if (!datePattern.hasMatch(value)) {
                return 'Formato de fecha inválido. Debe ser YYYY-MM-DD';
              }
              return null;
            },
          ),
          RoundedInputField(
            labelText: 'Altura (en cm)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su fecha de nacimiento';
              }
              RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
              if (!datePattern.hasMatch(value)) {
                return 'Formato de fecha inválido. Debe ser YYYY-MM-DD';
              }
              return null;
            },
          ),
          RoundedInputField(
            labelText: 'Peso (en kg)',
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su peso';
              }
              try {
                double.parse(value);
              } catch (e) {
                return 'Ingrese un peso válido (solo números)';
              }
              return null;
            },
          ),
          SubmitButton(
              text: "Ingresar",
              onPressed: () {
                final userData = collectUserData();
                widget.registerFunction(userData);
              })
        ]));
  }
}
