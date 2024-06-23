import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_actividad_dialog.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_actividad_edit_dialog.dart';
import 'package:fitsolutions/Components/CommonComponents/info_item.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaActividad extends StatelessWidget {
  final Actividad actividad;

  const CartaActividad({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserData>();
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: InkWell(
        onTap: userData.esBasico()
            ? () => showDialog(
                  context: context,
                  builder: (context) => ActividadDialog(
                    actividad: actividad,
                    onClose: () => Navigator.pop(context),
                  ),
                )
            : null,
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      actividad.nombre,
                      style: TextStyle(
                        fontSize: const TextStyle(fontSize: 35.0).fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    InfoItem(
                      icon: const Icon(Icons.timer, size: 20),
                      text:
                          "${Formatters().formatTimestampTime(actividad.inicio)}  ${Formatters().formatTimestampTime(actividad.fin)}",
                    ),
                    if (!userData.esBasico())
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                                    showDialog(
                                        context: context,
                                        builder: (context) =>
                                            CalendarioActividadEditDialog(
                                              actividad: actividad,
                                            ));
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
                                        content: Text(
                                          '¿Está seguro de que desea eliminar la actividad "${actividad.nombre}"?',
                                          style: const TextStyle(
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
                                            onPressed: () {
                                              Navigator.pop(context);
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
                      ),
                  ],
                ),
              ),
            ),
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
                      Text(
                        actividad.participantes.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 50,
                        height: 5.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        actividad.cupos.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      const SizedBox(height: 8.0),
                      const Text("Participantes",
                          style: TextStyle(
                            color: Colors.white,
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
