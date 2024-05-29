import 'package:flutter/material.dart';

class CalendarioForm extends StatefulWidget {
  const CalendarioForm({super.key});

  @override
  _CalendarioFormState createState() => _CalendarioFormState();
}

class _CalendarioFormState extends State<CalendarioForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(child: Text("LUNES")),
        Container(child: Text("MARTES")),
        Container(child: Text("MIERCOLES")),
        Container(child: Text("JUEVES")),
        Container(child: Text("VIERNES")),
      ]),
    ));
  }
}
