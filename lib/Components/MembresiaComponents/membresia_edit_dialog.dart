import 'dart:developer';

import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaEdit extends StatelessWidget {
  final Membresia membresia;
  final VoidCallback onClose;
  const MembresiaEdit(
      {super.key, required this.membresia, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nombreMembresia =
        TextEditingController(text: membresia.nombreMembresia);
    final _costoMembresia =
        TextEditingController(text: membresia.costo.toString());
    final _descripcionMembresia =
        TextEditingController(text: membresia.descripcion);

    Map<String, dynamic> collectMembresiaData() {
      return {
        'nombreMembresia': _nombreMembresia.text,
        'costo': _costoMembresia.text,
        'descripcion': _descripcionMembresia.text,
        'origenMembresia': membresia.id
      };
    }

    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                      'Editar Membresia',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RoundedInputField(
                    labelText: "Nombre",
                    controller: _nombreMembresia,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese el nombre de la membresia';
                      }
                      return null;
                    },
                  ),
                  RoundedInputField(
                    labelText: "Costo",
                    controller: _costoMembresia,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el costo de la membresia';
                      }
                      final double? parsedValue = double.tryParse(value);
                      if (parsedValue == null) {
                        return 'El costo debe ser un número válido.';
                      }
                      return null;
                    },
                  ),
                  RoundedInputField(
                    maxLines: 4,
                    labelText: '',
                    controller: _descripcionMembresia,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese una descripcion de la membresia';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              SubmitButton(
                text: "Actualizar",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, dynamic> membresiaData =
                        collectMembresiaData();
                    final success = await membresiaProvider
                        .actualizarMembresia(membresiaData);
                    if (success) {
                      debugger();
                      return const ResultDialog(
                          text: "Membresia actualizada exitosamente",
                          resultType: ResultType.success);
                    } else {
                      const ResultDialog(
                          text: "Error al actualizar membresia",
                          resultType: ResultType.error);
                    }
                  } else {
                    return const ResultDialog(
                        text: "Campos con errores",
                        resultType: ResultType.warning);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
