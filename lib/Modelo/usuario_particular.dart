import 'package:fitsolutions/Modelo/usuario.dart';
import 'package:fitsolutions/Modelo/usuario_basico.dart';

class UsuarioParticular extends Usuario {
  String nombreCompleto;
  String telefono;
  late List<UsuarioBasico> clientes;

  UsuarioParticular(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono});
}
