import 'package:fitsolutions/Modelo/Gimnasio.dart';
import 'package:fitsolutions/Modelo/UsuarioParticular.dart';
import 'package:flutter/material.dart';

class CalendarioBoard extends StatefulWidget {
  final Gimnasio? gimnasio;
  final UsuarioParticular? usuarioParticular;

  const CalendarioBoard({
    Key? key,
    this.gimnasio,
    this.usuarioParticular,
  });

  @override
  State<CalendarioBoard> createState() => _CalendarioBoardState();
}

class _CalendarioBoardState extends State<CalendarioBoard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border:
              TableBorder.all(color: Theme.of(context).colorScheme.secondary),
          children: const [
            TableRow(
              children: [
                TableCell(child: Text("Lunes")),
                TableCell(child: Text("Martes")),
                TableCell(child: Text("Miercoles")),
                TableCell(child: Text("Jueves")),
                TableCell(child: Text("Viernes")),
              ],
            ),
            TableRow(
              children: [
                TableCell(child: Text("")), // Empty cell for Monday
                TableCell(child: Text("")), // Empty cell for Tuesday
                TableCell(child: Text("")), // Empty cell for Wednesday
                TableCell(child: Text("")), // Empty cell for Thursday
                TableCell(child: Text("")), // Empty cell for Friday
              ],
            ),
          ],
        ),
      ),
    );
  }
}
