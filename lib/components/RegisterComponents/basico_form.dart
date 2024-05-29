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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1940),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(children: [
          const Text(
            'Formulario de Usuario Basico',
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
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            child: TextFormField(
              controller: _dateOfBirthController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su fecha de nacimiento';
                }
                return null;
              },
              decoration: InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide:
                        const BorderSide(color: Colors.orange, width: 2.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange))),
              readOnly: true,
              onTap: () {
                _selectDate();
              },
            ),
          ),
          RoundedInputField(
            labelText: 'Altura (en cm)',
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su altura';
              }
              try {
                double.parse(value);
              } catch (e) {
                return 'Ingrese una altura válida (solo números)';
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
                if (_formKey.currentState!.validate()) {
                  final userData = collectUserData();
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
