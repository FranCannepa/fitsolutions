import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            'Bienvenido!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Nombre Completo',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(CupertinoIcons.person_solid),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su nombre completo';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: _dateOfBirthController,
              decoration: InputDecoration(
                hintText: 'Fecha de nacimiento',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.calendar_today),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su fecha de nacimiento';
                }
                DateTime? birthDate;
                try {
                  birthDate = DateTime.parse(
                      value);
                } catch (e) {
                  return 'Formato de fecha no válido';
                }

                final today = DateTime.now();
                if (birthDate.isAfter(today)) {
                  return 'La fecha de nacimiento no puede ser en el futuro.';
                }

                var age = today.year - birthDate.year;
                if (today.month < birthDate.month ||
                    (today.month == birthDate.month &&
                        today.day < birthDate.day)) {
                  age--;
                }

                if (age < 18) {
                  return 'Debes tener al menos 18 años.';
                }

                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: _heightController,
              decoration: InputDecoration(
                hintText: 'Altura (en cm)',
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(CupertinoIcons.arrow_up_down_circle_fill),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su altura';
                }
                try {
                  double.parse(value);
                  if (double.tryParse(value)! <= 0) {
                    return 'Ingrese un valor positivo mayor a cero';
                  }
                } catch (e) {
                  return 'Ingrese una altura válida (solo números)';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                hintText: 'Peso (en kg)',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(CupertinoIcons.gauge),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su peso';
                }
                try {
                  double.parse(value);
                  if (double.tryParse(value)! <= 0) {
                    return 'Ingrese un valor positivo mayor a cero';
                  }
                } catch (e) {
                  return 'Ingrese un peso válido (solo números)';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          SubmitButton(
            text: 'Ingresar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final userData = collectUserData();
                widget.registerFunction(userData);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Errores en el Formulario")),
                );
              }
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
