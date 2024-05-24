import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:fitsolutions/Modelo/Ejercicio.dart';
import 'package:fitsolutions/Modelo/Usuario.dart';

class UsuarioBasico extends Usuario {
  List<Dieta> dietas;
  List<Ejercicio> ejercicios;

  UsuarioBasico({
    required String id,
    required String nombre,
    required String apellido,
    required String email,
    required this.dietas,
    required this.ejercicios,
  }) : super(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: email,
      tipoUsuario: "Basico"
  );

  @override
  Calendario getCalendario() {
    // TODO: implement getActividades
    throw UnimplementedError();
  }
}
