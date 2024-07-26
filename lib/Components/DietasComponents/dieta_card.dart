import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/components/DietasComponents/dieta_asignar_dialog.dart';
import 'package:fitsolutions/components/DietasComponents/dieta_edit_form.dart';
import 'package:fitsolutions/providers/dietas_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DietaCard extends StatelessWidget {
  final Dieta dieta;
  const DietaCard({super.key, required this.dieta});

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    final DietaProvider dietaProvider = context.read<DietaProvider>();
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.all(10),
      child: InkWell(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    dieta.nombre,
                    style: TextStyle(
                      fontSize: const TextStyle(fontSize: 35.0).fontSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!userProvider.esBasico()) const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.black),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DietaEditForm(
                                          dieta: dieta,
                                          onClose: () => Navigator.pop(context),
                                          dietaProvider: dietaProvider,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text(
                                          'Confirmar eliminación',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        content: const Text(
                                          '¿Está seguro de que desea eliminar esta dieta?',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              final success =
                                                  await dietaProvider
                                                      .eliminarDieta(dieta.id);
                                              if (success && context.mounted) {
                                                ModalUtils.showSuccessModal(
                                                    context,
                                                    'Dieta eliminada',
                                                    ResultType.success,
                                                    () =>
                                                        Navigator.pop(context));
                                              } else if (context.mounted) {
                                                ModalUtils.showSuccessModal(
                                                    context,
                                                    'Error al Eliminar Dieta',
                                                    ResultType.error,
                                                    () =>
                                                        Navigator.pop(context));
                                              }
                                            },
                                            child: const Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!userProvider.esBasico())
            Container(
              color: Colors.black,
              width: 130.0,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubmitButton(
                          text: "Asignar",
                          onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AsignarDietaDialog(
                                  dieta: dieta,
                                  onClose: () => Navigator.pop(context),
                                ),
                              ))
                    ],
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}
