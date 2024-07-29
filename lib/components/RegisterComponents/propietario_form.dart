import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text(
            'Bienvenido propietario!',
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
                prefixIcon: const Icon(Icons.person),
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
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
