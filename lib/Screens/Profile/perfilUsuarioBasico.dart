// import 'package:flutter/material.dart';

// class PerfilUsuarioBasico extends StatefulWidget {
//   const PerfilUsuarioBasico({super.key});

//   @override
//   _PerfilUsuarioBasicoState createState() => _PerfilUsuarioBasicoState();
// }

// class _PerfilUsuarioBasicoState extends State<PerfilUsuarioBasico> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

import 'package:flutter/material.dart';

class DailyActivityScreen extends StatefulWidget {
  @override
  State<DailyActivityScreen> createState() => _DailyActivityScreenState();
}

class _DailyActivityScreenState extends State<DailyActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Diarias'), // Daily Activities in Spanish
      ),
      body: const Column(
        children: [
          Text(
            'LUNES', // Monday in Spanish
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('ACTIVIDAD 1'),
                Spacer(),
                Text('ACTIVIDAD 2'), // Activity in Spanish
              ],
            ),
          ),
          Divider(thickness: 1.0),
          Text(
            'MARTES', // Tuesday in Spanish
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('ACTIVIDAD 1'),
                Spacer(),
                Text('ACTIVIDAD 2'), // Activity in Spanish
              ],
            ),
          ),
          Divider(thickness: 1.0),
          Text(
            'MIERCOLES', // Wednesday in Spanish
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('ACTIVIDAD 1'),
                Spacer(),
                Text('ACTIVIDAD 2'), // Activity in Spanish
              ],
            ),
          ),
          Divider(thickness: 1.0),
          Text(
            'JUEVES', // Thursday in Spanish
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('ACTIVIDAD 1'),
                Spacer(),
                Text('ACTIVIDAD 2'), // Activity in Spanish
              ],
            ),
          ),
          Divider(thickness: 1.0),
          Text(
            'VIERNES', // Friday in Spanish
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('ACTIVIDAD 1'),
                Spacer(),
                Text('ACTIVIDAD 2'), // Activity in Spanish
              ],
            ),
          ),
        ],
      ),
    );
  }
}
