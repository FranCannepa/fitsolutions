import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CalendarioBoard extends StatefulWidget {
  const CalendarioBoard({Key? key}) : super(key: key);

  @override
  _CalendarioBoardState createState() => _CalendarioBoardState();
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
                TableCell(
                  child: Text("Lunes"),
                ),
                TableCell(
                  child: Text("Martes"),
                ),
                TableCell(
                  child: Text("Miercoles"),
                ),
                TableCell(
                  child: Text("Jueves"),
                ),
                TableCell(
                  child: Text("Vienres"),
                )
              ],
            ),
            TableRow()
          ],
        ),
      ),
    );
  }
}
