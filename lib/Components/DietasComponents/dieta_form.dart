import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/input_row.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaForm extends StatefulWidget {
  final String origenDieta;
  const DietaForm({super.key, required this.origenDieta});

  @override
  _DietaFromState createState() => _DietaFromState();
}

class _DietaFromState extends State<DietaForm> {
  void _showSuccessModal(String mensaje, ResultType resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    ).then((_) {
      if (resultado == ResultType.success) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    final TextEditingController nombreController = TextEditingController();
    final TextEditingController maxCarbohidratosController =
        TextEditingController();
    final TextEditingController maxCaloriasController = TextEditingController();
    final _comidasController = <TextEditingController>[];

    final DietaProvider dietaProvider = context.read<DietaProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Dieta',
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
                        'origenDieta': widget.origenDieta,
                      };
                      final result =
                          await dietaProvider.agregarDieta(dietaData);
                      if (result) {
                        _showSuccessModal(
                            "Dieta creada exitosamente", ResultType.success);
                      } else {
                        _showSuccessModal(
                            "Error al crear dieta", ResultType.error);
                      }
                    }
                  },
                  text: "Crear Dieta",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
