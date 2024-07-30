import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/Plan/time_input_field.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';

import '../../components/components.dart';

class EjercicioCreateDialogue extends StatefulWidget {
  final FitnessProvider fitnessProvider;
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController durationController;
  final TextEditingController pausaController;
  final TextEditingController serieController;
  final TextEditingController repeticionController;
  final TextEditingController cargaController;
  final String? docId;
  final Plan? plan;
  final String? dia;
  final String? week;

  const EjercicioCreateDialogue(
      {super.key,
      required this.fitnessProvider,
      this.docId,
      this.plan,
      this.week,
      required this.nameController,
      required this.descController,
      required this.durationController,
      required this.pausaController,
      required this.serieController,
      required this.repeticionController,
      required this.cargaController,
      required this.dia});

  @override
  State<EjercicioCreateDialogue> createState() =>
      _EjercicioCreateDialogueState();
}

class _EjercicioCreateDialogueState extends State<EjercicioCreateDialogue> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _parentKey = GlobalKey<State>();

  void _clearFields() {
    widget.nameController.clear();
    widget.descController.clear();
    widget.durationController.clear();
    widget.pausaController.clear();
    widget.repeticionController.clear();
    widget.serieController.clear();
    widget.cargaController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: _parentKey,
      title: const Text('Datos del Ejercicio'),
      insetPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              RoundedInputField(
                controller: widget.nameController,
                labelText: 'Nombre del Ejercicio',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo no puede ser vacio';
                  }
                  return null;
                },
              ),
              RoundedInputField(
                controller: widget.descController,
                labelText: 'Descripcion',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo no puede ser vacio';
                  }
                  return null;
                },
              ),
              Row(children: [
                Expanded(
                  child: RoundedInputField(
                    controller: widget.serieController,
                    labelText: 'Series',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo no puede ser vacio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                      if (double.parse(value) < 0) {
                        return 'El número no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: RoundedInputField(
                    controller: widget.repeticionController,
                    labelText: 'Repeticiones',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo no puede ser vacio,\nescribir 0 si no corresponde';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Debe ser un número válido';
                      }
                      if (double.parse(value) < 0) {
                        return 'El número no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                ),
              ]),
              RoundedInputField(
                controller: widget.cargaController,
                labelText: 'Carga (KG)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El campo no puede ser vacio, escribir 0 si no corresponde';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Debe ser un número válido';
                  }
                  if (double.parse(value) < 0) {
                    return 'El número no puede ser negativo';
                  }
                  return null;
                },
              ),
              TimeInputField(
                  text: 'Ejecucion', controller: widget.durationController),
              TimeInputField(text: 'Pausa', controller: widget.pausaController),
            ]),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && widget.docId == null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDialog(
                          title: 'Crear Ejercicio',
                          content: 'Desea crear el Ejercicio?',
                          onConfirm: () async {
                            await widget.fitnessProvider.addEjercicioASemana(
                                widget.plan!,
                                widget.week!,
                                widget.nameController.text,
                                widget.descController.text,
                                int.parse(widget.serieController.text),
                                widget.repeticionController.text != ''
                                    ? int.parse(
                                        widget.repeticionController.text)
                                    : null,
                                widget.cargaController.text != ''
                                    ? int.parse(widget.cargaController.text)
                                    : null,
                                widget.durationController.text,
                                widget.pausaController.text,
                                widget.dia);
                            _clearFields();
                          },
                          parentKey: _parentKey);
                    });
              } else if (_formKey.currentState!.validate() &&
                  widget.docId != null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDialog(
                          title: 'Modificar Ejercicio',
                          content: 'Desea editar el Ejercicio?',
                          onConfirm: () async {
                            await widget.fitnessProvider.updateEjercicio(
                                widget.plan!,
                                widget.docId!,
                                widget.week!,
                                widget.nameController.text,
                                widget.descController.text,
                                int.parse(widget.serieController.text),
                                widget.repeticionController.text != ''
                                    ? int.parse(
                                        widget.repeticionController.text)
                                    : null,
                                widget.cargaController.text != ''
                                    ? int.parse(widget.cargaController.text)
                                    : null,
                                widget.durationController.text,
                                widget.pausaController.text);
                            _clearFields();
                          },
                          parentKey: _parentKey);
                    });
              }
              else{
                ModalUtils.showSuccessModal(context, 'El formulario cuenta con errores',ResultType.error, () => Navigator.pop(context));
              }
            },
            child: widget.docId == null
                ? const Text('Agregar')
                : const Text('Modificar'))
      ],
    );
  }
}
