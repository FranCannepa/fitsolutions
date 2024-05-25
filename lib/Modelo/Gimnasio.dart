import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/modelo/usuario_basico.dart';

class Gimnasio {
  String docId;
  String nombre;
  String ubicacion;
  List<UsuarioBasico> clientes;
  Calendario calendario;

  Gimnasio({
    required this.docId,
    required this.nombre,
    required this.ubicacion,
    required this.clientes,
    required this.calendario,
  });
}
