import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/usuario.dart';
import 'package:fitsolutions/Modelo/usuario_basico.dart';

class UsuarioParticular extends Usuario {
  List<UsuarioBasico> usuariosBasicos;
  Calendario calendario;

  UsuarioParticular({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required this.usuariosBasicos,
    required this.calendario,
  }) : super(
            tipoUsuario: "Particular");

  @override
  Calendario getCalendario() {
    // TODO: implement getActividades
    throw UnimplementedError();
  }
}
