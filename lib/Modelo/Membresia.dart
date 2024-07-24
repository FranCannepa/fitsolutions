class Membresia {
  final String id;
  final String nombreMembresia;
  final String costo;
  final String descripcion;
  final String origenMembresia;
  final int cupos;
  Membresia({
    required this.id,
    required this.nombreMembresia,
    required this.costo,
    required this.descripcion,
    required this.origenMembresia,
    required this.cupos,
  });

  static Membresia fromDocument(Map<String, dynamic> doc) {
    return Membresia(
        id: doc['membresiaId'],
        nombreMembresia: doc['nombreMembresia'],
        costo: doc['costo'],
        origenMembresia: doc['origenMembresia'],
        descripcion: doc['descripcion'],
        cupos:doc['cupos']);
  }
}
