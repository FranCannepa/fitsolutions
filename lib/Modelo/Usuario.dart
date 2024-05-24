import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Modelo/Calendario.dart';

abstract class Usuario {
  String docId;
  String email;
  Usuario({required this.docId, required this.email});
}
