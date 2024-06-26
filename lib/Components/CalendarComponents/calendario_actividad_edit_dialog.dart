import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/components/CommonComponents/input_date_picker.dart';
import 'package:fitsolutions/components/CommonComponents/input_dropdown.dart';
import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/input_time_picker.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarioActividadEditDialog extends StatefulWidget {
  final Actividad actividad;
  final VoidCallback onClose;
  const CalendarioActividadEditDialog(
      {super.key, required this.actividad, required this.onClose});

  @override
  State<CalendarioActividadEditDialog> createState() =>
      _CalendarioActividadEditDialogState();
}

class _CalendarioActividadEditDialogState
    extends State<CalendarioActividadEditDialog> {
  late TimeOfDay horaInicioUpdated =
      Formatters().timestampToTimeOfDay(widget.actividad.inicio);
  late TimeOfDay horaFinUpdated =
      Formatters().timestampToTimeOfDay(widget.actividad.fin);

  late DateTime fechaSelected = widget.actividad.inicio.toDate();
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> actividadData = {};

    final _formKey = GlobalKey<FormState>();
    final nombreActividadController =
        TextEditingController(text: widget.actividad.nombre);
    final tipoActividadController =
        TextEditingController(text: widget.actividad.tipo);
    final cuposActividadController =
        TextEditingController(text: widget.actividad.cupos.toString());
    late DateTime fechaActividad = DateTime.now();
    late TimeOfDay horaInicioActividadSeleccionada =
        Formatters().timestampToTimeOfDay(widget.actividad.inicio);
    late TimeOfDay horaFinActividadSeleccionada =
        Formatters().timestampToTimeOfDay(widget.actividad.fin);

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

    void summarizeData() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        actividadData['id'] = widget.actividad.id;
        actividadData['tipo'] = tipoActividadController.text;
        actividadData['nombreActividad'] = nombreActividadController.text;
        actividadData['inicio'] = Timestamp.fromDate(
            Formatters().combineDateTime(fechaSelected, horaInicioUpdated));
        actividadData['fin'] = Timestamp.fromDate(
            Formatters().combineDateTime(fechaSelected, horaFinUpdated));
        actividadData['cupos'] =
            int.tryParse(cuposActividadController.text) ?? 0;
        actividadData['participantes'] = 0;
      } else {}
    }

    final ActividadProvider actividadProvider =
        context.read<ActividadProvider>();

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
                        'Editar Actividad',
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
                ),
                InputDropdown(
                    labelText: "Tipo",
                    controller: tipoActividadController,
                    options: const ["Definida", "Mixta"]),
                RoundedInputField(
                    labelText: "Cupos", controller: cuposActividadController),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InputTimePicker(
                      labelText:
                          Formatters().timeOfDayString(horaInicioUpdated),
                      horaSeleccionada: horaInicioActividadSeleccionada,
                      onTimeSelected: (time) {
                        setState(() {
                          horaInicioUpdated = time;
                        });
                      },
                    ),
                    InputTimePicker(
                      labelText: Formatters().timeOfDayString(horaFinUpdated),
                      horaSeleccionada: horaFinActividadSeleccionada,
                      onTimeSelected: (time) {
                        setState(() {
                          horaFinUpdated = time;
                        });
                      },
                    ),
                    InputDatePicker(
                        labelText:
                            Formatters().formatDateDayMonthShort(fechaSelected),
                        fechaSeleccionada: fechaActividad,
                        onDateSelected: (date) {
                          setState(() {
                            fechaSelected = date;
                          });
                        }),
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
                            final result = await actividadProvider
                                .actualizarActividad(actividadData);
                            if (result) {
                              _showSuccessModal(
                                  "Actividad actualizada", ResultType.success);
                              _formKey.currentState!.reset();
                            } else {
                              _showSuccessModal(
                                  "Error al actualizar", ResultType.error);
                            }
                          } else {
                            _showSuccessModal("Campos Vacios", ResultType.info);
                          }
                        },
                        text: "Guardar",
                      ),
                      const SizedBox(width: 10.0),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
