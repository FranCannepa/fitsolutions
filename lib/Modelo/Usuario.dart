import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Modelo/Calendario.dart';

abstract class Usuario {
  String id;
  String nombre;
  String apellido;
  String email;
  String tipoUsuario; // "Basico", "Particular", "Propietario"

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.tipoUsuario,
  });

  Calendario getCalendario();
}
