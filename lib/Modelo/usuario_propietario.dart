import 'package:fitsolutions/Modelo/Gimnasio.dart';
import 'package:fitsolutions/Modelo/Usuario.dart';

class UsuarioPropietario extends Usuario {
  String nombreCompleto;
  String telefono;
  late Gimnasio gimnasio;

  UsuarioPropietario(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono});
}
