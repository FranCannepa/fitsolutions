import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigator.dart';
import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Modelo/Screens.dart';
import 'package:flutter/material.dart';

class MisPlanesActividad extends StatefulWidget {
  final String actividadId;
  const MisPlanesActividad({super.key, required this.actividadId});

  @override
  State<MisPlanesActividad> createState() => _MisPlanesActividadState();
}

class _MisPlanesActividadState extends State<MisPlanesActividad> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [ScreenTitle(title: "Planes Actividad")],
      ),
      bottomNavigationBar:
          FooterBottomNavigationBar(initialScreen: ScreenType.misPlanes),
    );
  }
}
