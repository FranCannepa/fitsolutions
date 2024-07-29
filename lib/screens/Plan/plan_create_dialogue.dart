import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/providers/fitness_provider.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';

import '../../components/components.dart';

class PlanCreateDialogue extends StatefulWidget {
  final FitnessProvider fitnessProvider;
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController minWeightController;
  final TextEditingController maxWeightController;
  final TextEditingController maxHeightController;
  final TextEditingController minHeightController;
  final String? docId;

  const PlanCreateDialogue(
      {super.key,
      required this.fitnessProvider,
      this.docId,
      required this.nameController,
      required this.descController,
      required this.minWeightController,
      required this.maxWeightController,
      required this.maxHeightController,
      required this.minHeightController});

  @override
  State<PlanCreateDialogue> createState() => _PlanCreateDialogueState();
}

class _PlanCreateDialogueState extends State<PlanCreateDialogue> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _parentKey = GlobalKey<State>();

  void _clearFields() {
    widget.nameController.clear();
    widget.descController.clear();
    widget.minWeightController.clear();
    widget.maxWeightController.clear();
    widget.minHeightController.clear();
    widget.maxHeightController.clear();
  }

  Map<String, dynamic> createRangeMap(TextEditingController minController,
      TextEditingController maxController) {
    return {
      'min': minController.text,
      'max': maxController.text,
    };
  }

  @override
  void dispose() {
    widget.nameController.clear();
    widget.descController.clear();
    widget.minWeightController.clear();
    widget.maxWeightController.clear();
    widget.minHeightController.clear();
    widget.maxHeightController
        .clear(); // Dispose of controllers or other resources.
    super.dispose();
  }

  bool _validateRanges() {
    double? minWeight = double.tryParse(widget.minWeightController.text);
    double? maxWeight = double.tryParse(widget.maxWeightController.text);
    double? minHeight = double.tryParse(widget.minHeightController.text);
    double? maxHeight = double.tryParse(widget.maxHeightController.text);

    if (minWeight != null && maxWeight != null && minWeight > maxWeight) {
      return false;
    }
    if (minHeight != null && maxHeight != null && minHeight > maxHeight) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: _parentKey,
      title: const Text('Datos del Plan'),
      insetPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              RoundedInputField(
                controller: widget.nameController,
                labelText: 'Nombre del Plan',
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
              Row(
                children: [
                  Expanded(
                    child: RoundedInputField(
                      controller: widget.minWeightController,
                      labelText: 'Peso minimo (kg)',
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
                  const SizedBox(width: 10), // Adjust spacing between fields
                  Expanded(
                    child: RoundedInputField(
                      controller: widget.maxWeightController,
                      labelText: 'Peso maximo (kg)',
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
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RoundedInputField(
                      controller: widget.minHeightController,
                      labelText: 'Altura minima (cm)',
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
                  const SizedBox(width: 10), // Adjust spacing between fields
                  Expanded(
                    child: RoundedInputField(
                      controller: widget.maxHeightController,
                      labelText: 'Altura maxima (cm)',
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
                ],
              ),
            ]),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              final weight = createRangeMap(
                  widget.minWeightController, widget.maxWeightController);
              final height = createRangeMap(
                  widget.minHeightController, widget.maxHeightController);
              if (_formKey.currentState!.validate() &&
                  widget.docId == null &&
                  _validateRanges()) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDialog(
                          title: 'Crear Rutina',
                          content: '¿Crear la Rutina?',
                          onConfirm: () async {
                            await widget.fitnessProvider.addPlan(
                                widget.nameController.text,
                                widget.descController.text,
                                weight,
                                height);
                            _clearFields();
                          },
                          parentKey: _parentKey);
                    });
              } else if (_formKey.currentState!.validate() &&
                  _validateRanges()) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmDialog(
                          title: 'Modificar Rutina',
                          content: '¿Modificar la Rutina?',
                          onConfirm: () async {
                            await widget.fitnessProvider.updatePlan(
                                widget.docId!,
                                widget.nameController.text,
                                widget.descController.text,
                                weight,
                                height);
                            _clearFields();
                          },
                          parentKey: _parentKey);
                    });
              } else {
                ModalUtils.showSuccessModal(context, 'Validación fallida, verificar campos', ResultType.error, ()=>Navigator.pop(context));
              }
            },
            child: widget.docId == null
                ? const Text('Agregar')
                : const Text('Modificar'))
      ],
    );
  }
}
