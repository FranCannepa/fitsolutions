import 'package:flutter/material.dart';

class CalendarioForm extends StatefulWidget {
  const CalendarioForm({super.key});

  @override
  State<CalendarioForm> createState() => _CalendarioFormState();
}

class _CalendarioFormState extends State<CalendarioForm> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("LUNES"),
        Text("MARTES"),
        Text("MIERCOLES"),
        Text("JUEVES"),
        Text("VIERNES"),
      ]),
    ));
  }
}
