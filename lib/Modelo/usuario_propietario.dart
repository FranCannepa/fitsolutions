
import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/usuario.dart';
import 'package:fitsolutions/Modelo/usuario_basico.dart';

class UsuarioPropietario extends Usuario {
  List<UsuarioBasico> clientes;
  Calendario calendario;

  UsuarioPropietario({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required this.clientes,
    required this.calendario,
  }) : super(
            tipoUsuario: "Particular");

  @override
  Calendario getCalendario() {
    // TODO: implement getActividades
    throw UnimplementedError();
  }
}
