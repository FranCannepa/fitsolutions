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

    final formKey = GlobalKey<FormState>();
    final nombreActividadController =
        TextEditingController(text: widget.actividad.nombre);
    final tipoActividadController =
        TextEditingController(text: widget.actividad.tipo);
    final cuposActividadController =
        TextEditingController(text: widget.actividad.cupos.toString());

    void showSuccessModal(String mensaje, ResultType resultado) {
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
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
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

    String? validateTime(TimeOfDay? horaInicio, TimeOfDay? horaFin) {
      if (horaInicio != null && horaFin != null) {
        if (horaInicio.hour > horaFin.hour ||
            (horaInicio.hour == horaFin.hour &&
                horaInicio.minute >= horaFin.minute)) {
          return 'La hora de inicio debe ser antes de la hora de fin.';
        }
      }
      return null;
    }

  String? validateHoraInicioNotBeforeCurrent(TimeOfDay? horaInicio) {
    if (horaInicio != null) {
      final now = TimeOfDay.now();
      final nowInMinutes = now.hour * 60 + now.minute;
      final inicioInMinutes = horaInicio.hour * 60 + horaInicio.minute;
      final today = DateTime.now();
      if (inicioInMinutes < nowInMinutes && (fechaSelected.day == today.day || fechaSelected.isBefore(today))) {
        return 'La hora de inicio no puede ser antes de la hora actual.';
      }
    }
    return null;
  }

    String? validateDateNotBeforeCurrent(DateTime? date) {
      if (date != null) {
        final today = DateTime.now();
        final selectedDate = DateTime(date.year, date.month, date.day);
        final currentDate = DateTime(today.year, today.month, today.day);

        if (selectedDate.isBefore(currentDate)) {
          return 'La fecha no puede ser en el pasado.';
        }
      }
      return null;
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
          key: formKey,
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
                      horaSeleccionada: horaInicioUpdated,
                      onTimeSelected: (time) {
                        setState(() {
                          horaInicioUpdated = time;
                        });
                      },
                      validator: (value) {
                        return validateHoraInicioNotBeforeCurrent(
                          horaInicioUpdated,
                        );
                      },
                    ),
                    InputTimePicker(
                      labelText: Formatters().timeOfDayString(horaFinUpdated),
                      horaSeleccionada: horaFinUpdated,
                      onTimeSelected: (time) {
                        setState(() {
                          horaFinUpdated = time;
                        });
                      },
                      validator: (value) {
                        return validateTime(horaInicioUpdated,
                            horaFinUpdated);
                      },
                    ),
                    InputDatePicker(
                      labelText:
                          Formatters().formatDateDayMonthShort(fechaSelected),
                      fechaSeleccionada: fechaSelected,
                      onDateSelected: (date) {
                        setState(() {
                          fechaSelected = date;
                        });
                      },
                      validator: (value) {
                        return validateDateNotBeforeCurrent(fechaSelected);
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
                          if (formKey.currentState!.validate()) {
                            summarizeData();
                            final result = await actividadProvider
                                .actualizarActividad(actividadData);
                            if (result) {
                              showSuccessModal(
                                  "Actividad actualizada", ResultType.success);
                              formKey.currentState!.reset();
                            } else {
                              showSuccessModal(
                                  "Error al actualizar", ResultType.error);
                            }
                          } else {
                            showSuccessModal("Errores en el Formulario", ResultType.error);
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
