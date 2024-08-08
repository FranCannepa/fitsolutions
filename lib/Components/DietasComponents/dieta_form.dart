import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/input_row.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaForm extends StatefulWidget {
  final String origenDieta;
  const DietaForm({super.key, required this.origenDieta});

  @override
  State<DietaForm> createState() => _DietaFromState();
}

class _DietaFromState extends State<DietaForm> {
  String kcalValue = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController maxCaloriasController = TextEditingController();
  final comidasController = <TextEditingController>[];
  final List<TextEditingController> dayControllers = [];
  final List<TextEditingController> mealTypeControllers = [];
  final List<TextEditingController> kcalControllers = [];

  bool _isLoading = false;

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

  Future<void> _createDieta() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
        'topeCalorias': maxCaloriasController.text,
        'comidas': comidas,
        'origenDieta': widget.origenDieta,
      };

      final DietaProvider dietaProvider = context.read<DietaProvider>();
      final result = await dietaProvider.agregarDieta(dietaData);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        _showSuccessModal("Dieta creada exitosamente", ResultType.success);
      } else {
        _showSuccessModal("Error al crear dieta", ResultType.error);
      }
    } else {
      _showSuccessModal("Errores en el formulario", ResultType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmDialog(
                              title: 'Crear Dieta',
                              content: '¿Desea Crear Dieta?',
                              onConfirm: () async {
                                await _createDieta();
                              },
                              parentKey: null,
                            );
                          },
                        );
                      },
                      text: "Crear Dieta",
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
