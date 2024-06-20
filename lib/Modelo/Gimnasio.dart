class Gimnasio {
  final String gymId;
  final String nombreGimnasio;
  final String direccion;
  final String contacto;
  final String logoUrl;
  final String propietarioId;
  final Map<String, Map<String, String>> horario;

  Gimnasio({
    required this.gymId,
    required this.nombreGimnasio,
    required this.direccion,
    required this.contacto,
    required this.logoUrl,
    required this.propietarioId,
    required this.horario,
  });

  factory Gimnasio.fromFirestore(String id, Map<String, dynamic> data) {

    final horario = (data['horario'] as Map<String, dynamic>).map((key, value) {
      final openCloseMap = Map<String, String>.from(value as Map);
      return MapEntry(key, openCloseMap);
    });
    return Gimnasio(
      gymId: id,
      nombreGimnasio: data['nombreGimnasio'] ?? '',
      direccion: data['direccion'] ?? '',
      contacto: data['contacto'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      propietarioId: data['propietarioId'] ?? '',
      horario:horario,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombreGimnasio': nombreGimnasio,
      'direccion': direccion,
      'contacto': contacto,
      'logoUrl': logoUrl,
      'propietarioId': propietarioId,
      'horario': horario,
    };
  }
}
