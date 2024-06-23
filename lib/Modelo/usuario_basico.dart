import 'package:fitsolutions/Modelo/Usuario.dart';

class UsuarioBasico extends Usuario {
  String nombreCompleto;
  String telefono;
  int altura = 0;
  double peso = 0.0;
  String fcmToken;

  UsuarioBasico(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono, required this.fcmToken});

  static UsuarioBasico fromDocument(String docId, Map<String, dynamic> doc) {
    return UsuarioBasico(
        docId: docId,
        email: doc['email'],
        nombreCompleto: doc['nombreCompleto'],
        telefono: 'TEL',
        fcmToken: doc['fcmToken'] ?? '',
      );
  }

  static Map<String, dynamic> toDocument(UsuarioBasico u) {
    return {
      'email': u.email,
      'nombreCompleto': u.nombreCompleto,
      'peso': u.peso,
      'altura': u.altura,
      'fcmToken': u.fcmToken,
    };
  }
}
