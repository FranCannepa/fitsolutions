import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/Usuario.dart';
import 'package:fitsolutions/Modelo/UsuarioBasico.dart';

class UsuarioPropietario extends Usuario {
  List<UsuarioBasico> clientes;
  Calendario calendario;

  UsuarioPropietario({
    required String id,
    required String nombre,
    required String apellido,
    required String email,
    required this.clientes,
    required this.calendario,
  }) : super(
            id: id,
            nombre: nombre,
            apellido: apellido,
            email: email,
            tipoUsuario: "Particular");

  @override
  Calendario getCalendario() {
    // TODO: implement getActividades
    throw UnimplementedError();
  }
}
