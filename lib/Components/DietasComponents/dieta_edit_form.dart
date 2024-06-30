import 'package:fitsolutions/Components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/components/CommonComponents/input_row.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaEditForm extends StatefulWidget {
  final Dieta dieta;
  final DietaProvider dietaProvider;
  final VoidCallback onClose;
  const DietaEditForm(
      {super.key,
      required this.dieta,
      required this.dietaProvider,
      required this.onClose});

  @override
  State<DietaEditForm> createState() => _DietaEditFormState();
}

class _DietaEditFormState extends State<DietaEditForm> {
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
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nombreController =
        TextEditingController(text: widget.dieta.nombre);
    final TextEditingController maxCarbohidratosController =
        TextEditingController(text: widget.dieta.maxCarbohidratos);
    final TextEditingController maxCaloriasController =
        TextEditingController(text: widget.dieta.caloriasTotales);
    final _comidasController = <TextEditingController>[];
    final dieta = widget.dieta;
    final DietaProvider dietaProvider = context.read<DietaProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Dieta',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Lista de alimentos",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              RowInput(
                comidasController: _comidasController,
                initialComidas: dieta.comidas,
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: SubmitButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final comidas = [];
                      for (int i = 0; i < _comidasController.length; i++) {
                        if (_comidasController[i].text != "") {
                          comidas.add(_comidasController[i].text);
                        }
                      }
                      final Map<String, dynamic> dietaData = {
                        'nombreDieta': nombreController.text,
                        'topeCarbohidratos': maxCarbohidratosController.text,
                        'topeCalorias': maxCaloriasController.text,
                        'comidas': comidas,
                        'origenDieta': dieta.origenDieta,
                      };
                      final result =
                          await dietaProvider.actualizarDieta(dietaData);
                      if (result) {
                        _showSuccessModal("Dieta actualizada exitosamente",
                            ResultType.success);
                      } else {
                        _showSuccessModal(
                            "Error al actualizar dieta", ResultType.error);
                      }
                    }
                  },
                  text: "Actualizar",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
