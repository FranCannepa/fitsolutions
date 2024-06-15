import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:fitsolutions/Components/CommonComponents/inputDatePicker.dart';
//import 'package:fitsolutions/Components/CommonComponents/inputDropDown.dart';
//import 'package:fitsolutions/Components/CommonComponents/inputTimePicker.dart';
//import 'package:fitsolutions/Components/CommonComponents/resultDialog.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/components/CommonComponents/input_date_picker.dart';
import 'package:fitsolutions/components/CommonComponents/input_dropdown.dart';
import 'package:fitsolutions/components/CommonComponents/input_time_picker.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:flutter/material.dart';

class CalendarioAgregarActividadDialog extends StatefulWidget {
  final String propietarioActividadId;
  final VoidCallback onClose;

  const CalendarioAgregarActividadDialog({
    super.key,
    required this.propietarioActividadId,
    required this.onClose,
  });

  @override
  State<CalendarioAgregarActividadDialog> createState() =>
      _CalendarioAgregarActividadDialogState();
}

class _CalendarioAgregarActividadDialogState
    extends State<CalendarioAgregarActividadDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreActividadController = TextEditingController();
  final tipoActividadController = TextEditingController();
  final cuposActividadController = TextEditingController();
  late DateTime fechaActividad = DateTime.now();
  late TimeOfDay horaInicioActividadSeleccionada = TimeOfDay.now();
  late TimeOfDay horaFinActividadSeleccionada = TimeOfDay.now();

  Map<String, dynamic> actividadData = {};

  void summarizeData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      actividadData['tipo'] = tipoActividadController.text;
      actividadData['nombreActividad'] = nombreActividadController.text;
      actividadData['inicio'] = Timestamp.fromDate(Formatters()
          .combineDateTime(fechaActividad, horaInicioActividadSeleccionada));
      actividadData['fin'] = Timestamp.fromDate(Formatters()
          .combineDateTime(fechaActividad, horaFinActividadSeleccionada));
      actividadData['cupos'] = int.tryParse(cuposActividadController.text) ?? 0;
      actividadData['participantes'] = 0;
    } else {
      //print('Form is invalid.');
    }
  }

  Future<void> registrarActividad() async {
    summarizeData();
    actividadData['propietarioActividadId'] = widget.propietarioActividadId;
    //print(actividadData);

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('actividad')
          .add(actividadData);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        _showSuccessModal("Actividad Creada", ResultType.success);
        _formKey.currentState!.reset();
        widget.onClose;
      } else {
        _showSuccessModal("Error al crear", ResultType.error);
      }
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  void _showSuccessModal(String mensaje, ResultType resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundedInputField(
                  labelText: "Nombre Actividad",
                  controller: nombreActividadController),
              InputDropdown(
                  labelText: "Tipo",
                  controller: tipoActividadController,
                  options: const ["Mixto", "Libre", "Unica"]),
              RoundedInputField(
                  labelText: "Cupos", controller: cuposActividadController),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InputTimePicker(
                    labelText: "Hora Inicio",
                    horaSeleccionada: horaInicioActividadSeleccionada,
                    onTimeSelected: (time) {
                      setState(() {
                        horaInicioActividadSeleccionada = time;
                      });
                    },
                  ),
                  InputTimePicker(
                    labelText: "Hora Fin",
                    horaSeleccionada: horaFinActividadSeleccionada,
                    onTimeSelected: (time) {
                      setState(() {
                        horaFinActividadSeleccionada = time;
                      });
                    },
                  ),
                ],
              ),
              InputDatePicker(
                  labelText: "Fecha",
                  fechaSeleccionada: fechaActividad,
                  onDateSelected: (date) {
                    setState(() {
                      fechaActividad = date;
                    });
                  }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: registrarActividad,
                      child: const Text('Guardar'),
                    ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: widget.onClose,
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
