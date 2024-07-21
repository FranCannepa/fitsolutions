class Dieta {
  final String id;
  final String nombre;
  final String caloriasTotales;
  final List<Comida> comidas;

  final String origenDieta;

  Dieta(
      {required this.id,
      required this.nombre,
      required this.caloriasTotales,
      required this.comidas,
      required this.origenDieta});

  static Dieta fromDocument(Map<String, dynamic> doc) {
    final id = doc['dietaId'];
    final nombre = doc['nombreDieta'];
    final caloriasTotales = doc['topeCalorias'];
    List<dynamic> comidasArray = doc['comidas'] ?? [];
    List<Comida> comidasList = comidasArray.map((comida) {
      return Comida.fromMap(comida as Map<String, dynamic>);
    }).toList();

    final origenDieta = doc['origenDieta'];
    return Dieta(
        id: id,
        nombre: nombre,
        caloriasTotales: caloriasTotales,
        comidas: comidasList,
        origenDieta: origenDieta);
  }

  Map<String, dynamic> toDocument() {
    return {
      'id': id,
      'nombre': nombre,
      'caloriasTotales': caloriasTotales,
      'comidas': comidas,
      'origenDieta': origenDieta
    };
  }
}

class Comida {
  String comida;
  String dia;
  String kcal;
  String meal;

  Comida({
    required this.comida,
    required this.dia,
    required this.kcal,
    required this.meal,
  });

  factory Comida.fromMap(Map<String, dynamic> map) {
    return Comida(
      comida: map['comida'] as String,
      dia: map['dia'] as String,
      kcal: map['kcal'] as String,
      meal: map['meal'] as String,
    );
  }
}
