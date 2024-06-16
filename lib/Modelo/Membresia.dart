class Membresia {
  final String id;
  final String nombreMembresia;
  final String costo;
  final String descripcion;
  final String origenMembresia;
  Membresia({
    required this.id,
    required this.nombreMembresia,
    required this.costo,
    required this.descripcion,
    required this.origenMembresia,
  });

  static Membresia fromDocument(Map<String, dynamic> doc) {
    return Membresia(
        id: doc['membresiaId'],
        nombreMembresia: doc['nombreMembresia'],
        costo: doc['costo'],
        origenMembresia: doc['origenMembresia'],
        descripcion: doc['descripcion']);
  }
}
