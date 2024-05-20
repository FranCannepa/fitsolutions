import 'package:fitsolutions/Modelo/Calendario.dart';
import 'package:fitsolutions/Modelo/dieta.dart';
import 'package:fitsolutions/Modelo/ejercicio.dart';
import 'package:fitsolutions/Modelo/usuario.dart';

class UsuarioBasico extends Usuario {
  List<Dieta> dietas;
  List<Ejercicio> ejercicios;

  UsuarioBasico({
    required super.id,
    required super.nombre,
    required super.apellido,
    required super.email,
    required this.dietas,
    required this.ejercicios,
  }) : super(
      tipoUsuario: "Basico"
  );

  @override
  Calendario getCalendario() {
    // TODO: implement getActividades
    throw UnimplementedError();
  }
}
