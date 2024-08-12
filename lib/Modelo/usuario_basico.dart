import 'package:fitsolutions/Modelo/Usuario.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class UsuarioBasico extends Usuario {
  String nombreCompleto;
  String telefono;
  int altura = 0;
  double peso = 0.0;
  String fcmToken;
  String rutina;  
  String fechaNacimiento;

  UsuarioBasico(
      {required super.docId,
      required super.email,
      required this.nombreCompleto,
      required this.telefono, required this.fcmToken,
      required this.rutina,
      required this.fechaNacimiento});

  static UsuarioBasico fromDocument(String docId, Map<String, dynamic> doc) {
    return UsuarioBasico(
        docId: docId,
        email: doc['email'] ?? '',
        nombreCompleto: doc['nombreCompleto'] ?? '',
        telefono: 'TEL',
        fcmToken: doc['fcmToken'] ?? '',
        rutina: doc['rutina'] ?? '',
        fechaNacimiento: doc['fechaNacimiento'] ?? ''
      );
  }

    int getAge() {
    try{
    final birthDateFormat = DateFormat('yyyy-MM-dd');
    final birthDateParsed = birthDateFormat.parse(fechaNacimiento);
    final today = DateTime.now();
    int age = today.year - birthDateParsed.year;
    if (today.month < birthDateParsed.month ||
        (today.month == birthDateParsed.month && today.day < birthDateParsed.day)) {
      age--;
    }
    return age;
    }
    catch(e){
      Logger().d(e);
      return 0;
    }
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

  static bool hasAttribute(UsuarioBasico u, String attributeName) {
    var attributes = toDocument(u);
    return attributes.containsKey(attributeName);
  }
}
