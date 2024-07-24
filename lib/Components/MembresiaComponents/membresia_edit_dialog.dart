import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaEdit extends StatefulWidget {
  final Membresia membresia;
  final VoidCallback onClose;
  const MembresiaEdit(
      {super.key, required this.membresia, required this.onClose});

  @override
  State<MembresiaEdit> createState() => _MembresiaEditState();
}

class _MembresiaEditState extends State<MembresiaEdit> {
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
    final formKey = GlobalKey<FormState>();
    final nombreMembresia =
        TextEditingController(text: widget.membresia.nombreMembresia);
    final costoMembresia =
        TextEditingController(text: widget.membresia.costo.toString());
    final descripcionMembresia =
        TextEditingController(text: widget.membresia.descripcion);
    final cuposMembresia =
        TextEditingController(text: widget.membresia.cupos.toString());

    Map<String, dynamic> collectMembresiaData() {
      return {
        'nombreMembresia': nombreMembresia.text,
        'costo': costoMembresia.text,
        'descripcion': descripcionMembresia.text,
        'origenMembresia': widget.membresia.id,
        'cupos': int.parse(cuposMembresia.text)
      };
    }

    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
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
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RoundedInputField(
                      labelText: "Nombre",
                      controller: nombreMembresia,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre de la membresia';
                        }
                        return null;
                      },
                    ),
                    RoundedInputField(
                      labelText: "Costo",
                      controller: costoMembresia,
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
                    const SizedBox(height: 16.0),
                    RoundedInputField(
                      keyboardType: TextInputType.number,
                      labelText: 'Cupos',
                      controller: cuposMembresia,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El número de cupos es obligatorio.';
                        } else {
                          try {
                            final int cupos = int.parse(value);
                            if (cupos < 0) {
                              return 'El número de cupos debe ser un número positivo.';
                            }
                          } on FormatException {
                            return 'El número de cupos debe ser un número válido.';
                          }
                        }
                        return null;
                      },
                    ),
                    RoundedInputField(
                      maxLines: 4,
                      labelText: '',
                      controller: descripcionMembresia,
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
                    if (formKey.currentState!.validate()) {
                      final Map<String, dynamic> membresiaData =
                          collectMembresiaData();
                      final success = await membresiaProvider
                          .actualizarMembresia(membresiaData);
                      if (success) {
                        _showSuccessModal(
                            "Membresia Editada", ResultType.success);
                        formKey.currentState!.reset();
                      } else {
                        _showSuccessModal("Error al editar", ResultType.error);
                      }
                    } else {
                      _showSuccessModal(
                          "Errores en el formulario", ResultType.info);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
