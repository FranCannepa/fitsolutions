import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Actividad {
  String id;
  String propietarioActividadId;
  String nombre;
  String tipo;
  Timestamp inicio;
  Timestamp fin;
  int cupos;
  int participantes;
  
  Actividad({
    required this.id,
    required this.propietarioActividadId,
    required this.nombre,
    required this.tipo,
    required this.inicio,
    required this.fin,
    required this.cupos,
    required this.participantes,
  });

  static Actividad fromDocument(Map<String, dynamic> doc) {
    return Actividad(
        id: doc['actividadId'],
        propietarioActividadId: doc['propietarioActividadId'],
        nombre: doc['nombreActividad'],
        cupos: doc['cupos'],
        participantes: doc['participantes'] ?? 0,
        inicio: doc['inicio'],
        fin: doc['fin'],
        tipo: doc['tipo']);
  }
}
