import 'package:fitsolutions/Utilities/formaters.dart';

class Gimnasio {
  final String id;
  final String nombreGimnasio;
  final String direccion_1;
  final String? direccion_2;
  final List<String> clientesId;
  final DateTime horarioApertura;
  final DateTime horarioClausura;
  final String? propietario;
  final String? celular;
  final String? telefono;

  Gimnasio({
    required this.id,
    required this.nombreGimnasio,
    required this.direccion_1,
    this.direccion_2,
    required this.clientesId,
    required this.horarioApertura,
    required this.horarioClausura,
    required this.propietario,
    required this.telefono,
    this.celular,
  });

  static Gimnasio fromDocument(Map<String, dynamic> doc) {
    return Gimnasio(
      id: doc['gimnasioId'] ?? '',
      nombreGimnasio: doc['nombreGimnasio'] ?? '',
      direccion_1: doc['direccion_1'] ?? '',
      direccion_2: doc['direccion_2'],
      clientesId: List<String>.from(doc['clientesId'] ?? const []),
      horarioApertura: Formatters().parseTimeFromString(doc['apertura']),
      horarioClausura: Formatters().parseTimeFromString(doc['clausura']),
      propietario: doc['propietarioId'],
      telefono: doc['telefono'],
      celular: doc['celular'],
    );
  }
}
