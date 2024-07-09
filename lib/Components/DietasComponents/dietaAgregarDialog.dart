import 'package:fitsolutions/Components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/input_row.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:flutter/material.dart';

class DietaAgregarDialog extends StatefulWidget {
  final String origenDieta;
  final VoidCallback onClose;
  const DietaAgregarDialog(
      {super.key, required this.origenDieta, required this.onClose});

  @override
  State<DietaAgregarDialog> createState() => _DietaAgregarDialogState();
}

class _DietaAgregarDialogState extends State<DietaAgregarDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController maxCarbohidratosController =
      TextEditingController();
  final TextEditingController maxCaloriasController = TextEditingController();
  String caloriasTotales = '';
  final _comidasController = <TextEditingController>[];

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
                      'Nueva dieta',
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              RoundedInputField(
                labelText: 'Nombre de la Dieta',
                controller: nombreController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un nombre para la dieta.';
                  }
                  return null;
                },
              ),
              RoundedInputField(
                labelText: 'Máximos Carbohidratos',
                controller: maxCarbohidratosController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor para los carbohidratos máximos.';
                  }
                  return null;
                },
              ),
              RoundedInputField(
                labelText: 'Máximos Calorias',
                controller: maxCaloriasController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor para las calorías máximas.';
                  }
                  return null;
                },
              ),
              RowInput(
                comidasController: _comidasController,
              ),
              SubmitButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, dynamic> dietaData = {
                      'nombre': nombreController.text,
                      'maxCarbohidratos': maxCarbohidratosController.text,
                      'caloriasTotales': maxCaloriasController.text,
                      'comidas': _comidasController,
                      'origenDieta': widget.origenDieta,
                    };
                  }
                },
                text: "Crear Dieta",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
