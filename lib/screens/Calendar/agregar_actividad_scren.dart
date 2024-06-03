import 'package:fitsolutions/Components/components.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AgregarActividadScreen extends StatefulWidget {
  final String dia;
  const AgregarActividadScreen({super.key, required this.dia});

  @override
  _AgregarActividadScrenState createState() => _AgregarActividadScrenState();
}

class _AgregarActividadScrenState extends State<AgregarActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreActividad = TextEditingController();
  late TimeOfDay horaInicioActividad;
  late TimeOfDay horaFinActividad;
  final nombreProfActividad = TextEditingController();

  Future<void> _registerActivity(String actividad) async {
    final collectionRef = FirebaseFirestore.instance.collection('actividades');
  }

  Map<String, dynamic> getDatosActividad() {
    return {
      'diaSemana': 0,
      'nombreActividad': nombreActividad.text,
      'horaInicio': horaInicioActividad,
      'horaFin': horaFinActividad,
      'nombreProfesor': nombreProfActividad.text,
      'capacidad': 15,
      'participantes': 0
    };
  }

  void _pickHoraInicio() {
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((value) {
      setState(() {
        horaInicioActividad = value!;
      });
    });
  }

  void _pickHoraFin() {
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((value) {
      setState(() {
        horaFinActividad = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundedInputField(
                  labelText: "Nombre Actividad",
                  controller: nombreActividad,
                ),
                RoundedInputField(
                    labelText: "Nombre Profesor",
                    controller: nombreProfActividad),
                MaterialButton(
                  onPressed: _pickHoraInicio,
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Seleccionar Hora Inicio"),
                  ),
                ),
                const SizedBox(height: 20.0),
                const Center(
                    child: Row(
                  children: [
                    // Text(horaInicioActividad.toString())
                  ],
                )),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final actividad = getDatosActividad();
                      print(actividad);
                      //_registerActivity(actividad);
                      // Handle successful registration (optional)
                    }
                  },
                  child: const Text('Registrar Actividad'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
