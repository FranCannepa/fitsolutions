import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/Usuario.dart';
import 'package:fitsolutions/Modelo/UsuarioBasico.dart';

class UsuarioParticular extends Usuario {
  String nombreCompleto;
  String telefono;
  late Calendario calendario;
  late List<UsuarioBasico> clientes;

  UsuarioParticular(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono});
}
