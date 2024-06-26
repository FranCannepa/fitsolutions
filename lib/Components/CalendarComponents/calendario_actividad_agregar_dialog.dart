import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/components/CommonComponents/input_date_picker.dart';
import 'package:fitsolutions/components/CommonComponents/input_dropdown.dart';
import 'package:fitsolutions/components/CommonComponents/input_time_picker.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:flutter/material.dart';

class CalendarioAgregarActividadDialog extends StatefulWidget {
  final String propietarioActividadId;
  final VoidCallback onClose;
  final ActividadProvider actividadProvider;

  const CalendarioAgregarActividadDialog({
    super.key,
    required this.propietarioActividadId,
    required this.onClose,
    required this.actividadProvider,
  });

  @override
  State<CalendarioAgregarActividadDialog> createState() =>
      _CalendarioAgregarActividadDialogState();
}

class _CalendarioAgregarActividadDialogState
    extends State<CalendarioAgregarActividadDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreActividadController = TextEditingController();
  final tipoActividadController = TextEditingController(text: "Definida");
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
      actividadData['propietarioActividadId'] = widget.propietarioActividadId;
    } else {}
  }

  void _showSuccessModal(String mensaje, ResultType resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    ).then((_) {
      if (resultado == ResultType.success) {
        widget.onClose();
      }
    });
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Nueva Actividad',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                RoundedInputField(
                  labelText: "Nombre Actividad",
                  controller: nombreActividadController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la actividad es obligatorio.';
                    }
                    return null;
                  },
                ),
                InputDropdown(
                  labelText: "Tipo",
                  controller: tipoActividadController,
                  options: const ["Definida", "Libre"],
                ),
                RoundedInputField(
                  labelText: "Cupos",
                  controller: cuposActividadController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debes especificar la cantidad de cupos.';
                    }
                    try {
                      int.parse(value);
                    } catch (e) {
                      return 'La cantidad de cupos debe ser un número.';
                    }
                    return null;
                  },
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    InputDatePicker(
                      labelText: "Fecha",
                      fechaSeleccionada: fechaActividad,
                      onDateSelected: (date) {
                        setState(() {
                          fechaActividad = date;
                        });
                      },
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubmitButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            summarizeData();
                            final result = await widget.actividadProvider
                                .registrarActividad(actividadData);
                            if (result) {
                              _showSuccessModal(
                                  "Actividad Creada", ResultType.success);
                              _formKey.currentState!.reset();
                            } else {
                              _showSuccessModal(
                                  "Error al crear", ResultType.error);
                            }
                          } else {
                            _showSuccessModal("Campos Vacios", ResultType.info);
                          }
                        },
                        text: "Agregar",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
