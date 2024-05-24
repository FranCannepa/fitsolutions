import 'package:fitsolutions/Modelo/Usuario.dart';

class UsuarioBasico extends Usuario {
  String nombreCompleto;
  String telefono;
  int altura = 0;
  double peso = 0.0;
  UsuarioBasico(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono});
}
