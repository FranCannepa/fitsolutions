import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Screens/Plan/misPlanesActividad.dart';
import 'package:flutter/material.dart';

class ActividadDialog extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback onClose;

  const ActividadDialog(
      {super.key, required this.actividad, required this.onClose});

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black,
                  child: Text(
                    actividad.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                )
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: SubmitButton(
                  text: "Ver mis planes",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MisPlanesActividad(
                          actividadId: actividad.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onClose,
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
