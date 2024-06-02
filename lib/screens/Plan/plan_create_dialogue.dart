import 'package:fitsolutions/providers/fitness_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Datos del Plan'),
      insetPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      labelText: 'Peso minimo',
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
                      labelText: 'Peso maximo',
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
                      labelText: 'Altura minima',
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
                      labelText: 'Altura maxima',
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
              if (_formKey.currentState!.validate() && widget.docId == null) {
                await widget.fitnessProvider.addPlan(widget.nameController.text,
                    widget.descController.text, weight, height);
                _clearFields();
                Navigator.pop(context);
                //Navigator.push(context,  MaterialPageRoute(builder: (context) =>  AgregarEjercicioScreen(plan: nuevoPlan)));
              } else if (_formKey.currentState!.validate()) {
                widget.fitnessProvider.updatePlan(
                    widget.docId!,
                    widget.nameController.text,
                    widget.descController.text,
                    weight,
                    height);
                _clearFields();
                Navigator.pop(context);
              }
            },
            child: widget.docId == null
                ? const Text('Agregar')
                : const Text('Modificar'))
      ],
    );
  }
}
