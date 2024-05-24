import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/UsuarioBasico.dart';

class Gimnasio {
  String id;
  String nombre;
  String ubicacion;
  List<UsuarioBasico> usuariosBasicos;
  Calendario calendario;

  Gimnasio({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.usuariosBasicos,
    required this.calendario,
  });
}
