class Dieta {
  final String id;
  final String nombre;
  final String maxCarbohidratos;
  final String caloriasTotales;
  final List<String> comidas;
  final String frecuenciaAlimentacion;
  final String origenDieta;

  Dieta(
      {required this.id,
      required this.nombre,
      required this.maxCarbohidratos,
      required this.caloriasTotales,
      required this.comidas,
      required this.frecuenciaAlimentacion,
      required this.origenDieta});

  static Dieta fromDocument(Map<String, dynamic> doc) {
    final id = doc['dietaId'];
    final nombre = doc['nombreDieta'];
    final maxCarbohidratos = doc['topeCarbohidratos'];
    final caloriasTotales = doc['topeCalorias'];
    final comidas = doc['listaAlimentos'].split(',');
    final frecuenciaAlimentacion = doc['frecuenciaAlimentacion'];
    final origenDieta = doc['origenDieta'];
    return Dieta(
        id: id,
        nombre: nombre,
        maxCarbohidratos: maxCarbohidratos,
        caloriasTotales: caloriasTotales,
        comidas: comidas,
        frecuenciaAlimentacion: frecuenciaAlimentacion,
        origenDieta: origenDieta);
  }

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'nombre': nombre,
      'maxCarbohidratos': maxCarbohidratos,
      'caloriasTotales': caloriasTotales,
      'comidas': comidas,
      'frecuenciaAlimentacion': frecuenciaAlimentacion,
      'origenDieta': origenDieta
    };
  }
}
