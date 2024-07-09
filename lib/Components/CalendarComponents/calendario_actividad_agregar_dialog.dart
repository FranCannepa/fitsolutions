import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
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
      actividadData['cupos'] = int.tryParse(cuposActividadController.text);
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

      if (inicioInMinutes < nowInMinutes) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPrefsHelper().getSubscripcion(),
      builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }else if(snapshot.data == null){
            return AlertDialog(
            title: const Text('Registro no completado'),
            content: const Text('Complete su registro completando sus datos de Entrenador o Gimnasio'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }else{
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
                          final cupos = int.parse(value);
                          if (cupos <= 0) {
                            return 'La cantidad de cupos debe ser un número positivo mayor que cero.';
                          }
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
                          validator: (value) {
                            return validateHoraInicioNotBeforeCurrent(
                                horaInicioActividadSeleccionada);
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
                          validator: (value) {
                            return validateTime(horaInicioActividadSeleccionada,
                                horaFinActividadSeleccionada);
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
                          validator: (value){
                            return validateDateNotBeforeCurrent(fechaActividad);
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
                                _showSuccessModal("Errores en el formulario", ResultType.info);
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
    );
  }
}
