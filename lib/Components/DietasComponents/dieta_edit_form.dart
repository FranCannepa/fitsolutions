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

  final comidasController = <TextEditingController>[];
  final List<TextEditingController> dayControllers = [];
  final List<TextEditingController> mealTypeControllers = [];
  final List<TextEditingController> kcalControllers = [];

  void rowData() {
    List<Comida> comidas = widget.dieta.comidas;
    for (var i = 0; i < comidas.length; i++) {
      comidasController.add(TextEditingController(text: comidas[i].comida));
      dayControllers.add(TextEditingController(text: comidas[i].dia));
      mealTypeControllers.add(TextEditingController(text: comidas[i].meal));
      kcalControllers.add(TextEditingController(text: comidas[i].kcal));
    }
  }

  @override
  void initState() {
    super.initState();
    rowData();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nombreController =
        TextEditingController(text: widget.dieta.nombre);
    final TextEditingController maxCaloriasController =
        TextEditingController(text: widget.dieta.caloriasTotales);
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
          key: formKey,
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
                labelText: 'Máximos Calorias',
                controller: maxCaloriasController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor para las calorías máximas.';
                  }
                  int? maxCal = int.tryParse(value);
                  if (maxCal == null) {
                    return 'El valor debe ser numerico';
                  }
                  if (maxCal <= 0) {
                    return 'El valor debe ser un numero positivo';
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
                comidasController: comidasController,
                maxCaloriasController: maxCaloriasController,
                dayControllers: dayControllers,
                mealTypeControllers: mealTypeControllers,
                kcalControllers: kcalControllers,
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: SubmitButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final comidas = [];
                      for (int i = 0; i < comidasController.length; i++) {
                        if (comidasController[i].text != "") {
                          comidas.add({
                            'comida': comidasController[i].text,
                            'dia': dayControllers[i].text,
                            'meal': mealTypeControllers[i].text,
                            'kcal': kcalControllers[i].text
                          });
                        }
                      }
                      final Map<String, dynamic> dietaData = {
                        'nombreDieta': nombreController.text,
                        /*'topeCarbohidratos': maxCarbohidratosController.text,*/
                        'topeCalorias': maxCaloriasController.text,
                        'comidas': comidas,
                        'origenDieta': dieta.origenDieta,
                      };
                      final result = await dietaProvider.actualizarDieta(
                          dietaData, dieta.id);
                      if (result) {
                        _showSuccessModal("Dieta actualizada exitosamente",
                            ResultType.success);
                      } else {
                        _showSuccessModal(
                            "Error al actualizar dieta", ResultType.error);
                      }
                    } else {
                      _showSuccessModal(
                          "Errores en el formulario", ResultType.warning);
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
