import 'package:fitsolutions/Components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaFormDialog extends StatefulWidget {
  final String origenMembresia;
  final VoidCallback onClose;
  const MembresiaFormDialog(
      {super.key, required this.origenMembresia, required this.onClose});

  @override
  State<MembresiaFormDialog> createState() => _MembresiaFormState();
}

class _MembresiaFormState extends State<MembresiaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreMembresia = TextEditingController();
  final _costoMembresia = TextEditingController();
  final _descripcionMembresia = TextEditingController();
  final _cuposController = TextEditingController();
  late Map<String, dynamic> membresiaData = {};
  bool showMembresiaForm = false;

  Map<String, dynamic> collectMembresiaData() {
    return {
      'nombreMembresia': _nombreMembresia.text,
      'costo': _costoMembresia.text,
      'descripcion': _descripcionMembresia.text,
      'origenMembresia': widget.origenMembresia,
      'cupos': int.tryParse(_cuposController.text) ?? 0,
    };
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
    final membresiaProvider = context.read<MembresiaProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
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
                        'Nueva Membresia',
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                RoundedInputField(
                  labelText: 'Nombre',
                  controller: _nombreMembresia,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la membresia es obligatorio.';
                    } else if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                RoundedInputField(
                  keyboardType: TextInputType.number,
                  labelText: 'Costo',
                  controller: _costoMembresia,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El costo de la membresia es obligatorio.';
                    } else {
                      try {
                        final double costo = double.parse(value);
                        if (costo <= 0) {
                          return 'El costo debe ser un número positivo.';
                        }
                      } on FormatException {
                        return 'El costo debe ser un número válido.';
                      }
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              RoundedInputField(
                keyboardType: TextInputType.number,
                labelText: 'Cupos',
                controller: _cuposController,
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
                const SizedBox(height: 16.0),
                RoundedInputField(
                  labelText: 'Descripcion',
                  controller: _descripcionMembresia,
                  maxLines: 7,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción de la membresia es obligatoria.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                SubmitButton(
                  text: "Registrar",
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final Map<String, dynamic> membresiaData =
                          collectMembresiaData();
                      final success = await membresiaProvider
                          .registrarMembresia(membresiaData);
                      if (success) {
                        _showSuccessModal(
                            "Membresia creada exitosamente", ResultType.success);
                      } else {
                        _showSuccessModal(
                            "Error al crear la membresia", ResultType.error);
                      }
                    }
                    else{
                        _showSuccessModal(
                            "Errores en el Formulario", ResultType.error);
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
