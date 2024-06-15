import 'package:fitsolutions/Components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
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
  String caloriasTotales = '';
  List<String> comidas = [];
  final TextEditingController frecuenciaAlimentacionController =
      TextEditingController();

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
              const ScreenSubTitle(text: "Nueva Dieta"),
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
                controller: maxCarbohidratosController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor para los carbohidratos máximos.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, dynamic> dietaData = {
                      'nombre': nombreController.text,
                      'maxCarbohidratos': maxCarbohidratosController.text,
                      'caloriasTotales': caloriasTotales,
                      'comidas': comidas,
                      'frecuenciaAlimentacion':
                          frecuenciaAlimentacionController.text,
                      'origenDieta': widget.origenDieta,
                    };
                  }
                },
                child: const Text('Crear Dieta'),
              ),
              TextButton(
                onPressed: widget.onClose,
                child: Text(
                  "Cancelar",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
