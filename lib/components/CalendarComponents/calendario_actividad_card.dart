import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_actividad_dialog.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendario_actividad_edit_dialog.dart';
import 'package:fitsolutions/Components/CommonComponents/info_item.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/CalendarComponents/actividad_participantes.dart';
import 'package:fitsolutions/providers/actividad_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartaActividad extends StatefulWidget {
  final Actividad actividad;

  const CartaActividad({super.key, required this.actividad});

  @override
  State<CartaActividad> createState() => _CartaActividadState();
}

class _CartaActividadState extends State<CartaActividad> {

  String? subId;

  @override
  void initState() {
    super.initState();
    getSubId();
  }

  Future<void> getSubId() async{
    final prefs = SharedPrefsHelper();
    final result = await prefs.getSubscripcion();
    setState(() {
      subId = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = context.read<UserData>();
    final ActividadProvider actividadProvider =
        context.read<ActividadProvider>();
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
                    actividad: widget.actividad,
                    onClose: () => Navigator.pop(context),
                  ),
                )
            : subId != null ? () => showDialog(
                  context: context,
                  builder: (context) => ActividadParticipantes(
                    actividadId: widget.actividad.id,
                    onClose: () => Navigator.pop(context),
                  ),
                ) : null,
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
                      widget.actividad.nombre,
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
                          "${Formatters().formatTimestampTime(widget.actividad.inicio)}  ${Formatters().formatTimestampTime(widget.actividad.fin)}",
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
                                              actividad: widget.actividad,
                                              onClose: () {
                                                Navigator.pop(context);
                                              },
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
                                          '¿Está seguro de que desea eliminar la actividad "${widget.actividad.nombre}"?',
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
                                            onPressed: () async {
                                              final result =
                                                  await actividadProvider
                                                      .eliminarActividad(
                                                          widget.actividad.id);
                                              if (result) {
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
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
                        widget.actividad.participantes.toString(),
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
                        widget.actividad.cupos.toString(),
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
