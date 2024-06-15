import 'package:cloud_firestore/cloud_firestore.dart';

class Actividad {
  String id;
  String nombre;
  String descripcion;
  String tipo;
  Timestamp inicio;
  Timestamp fin;
  int cupos;
  int participantes;
  Actividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.inicio,
    required this.fin,
    required this.cupos,
    required this.participantes,
  });
}
