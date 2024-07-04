import 'package:fitsolutions/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const SizedBox(height: 30),
          const Text(
            'Bienvenido entrenador!',
            style: TextStyle(
              fontFamily: 'Sora',
              color: Colors.white,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 35,
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
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                )
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su nombre completo';
                }
                return null;
              },
            )
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
              })
        ]));
  }
}
