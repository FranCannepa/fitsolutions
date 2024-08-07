class Ejercicio {
  String id;
  String nombre;
  String descripcion;
  String tipo; // "Cardio", "Fuerza", "Flexibilidad"
  String duracion; // ejecucion en minutos
  int series;
  int? repeticiones;
  String? pausas;
  int? carga;
  String? dia;

  Ejercicio(
      {
      required this.id,
      required this.nombre,
      required this.descripcion,
      required this.tipo,
      required this.duracion,
      required this.series,
      this.repeticiones,
      this.pausas,
      this.carga,
      this.dia
      });

  static Ejercicio fromDocument(String id, Map<String, dynamic> doc) {
    return Ejercicio(
      id: id, 
      nombre: doc['nombre'],
      descripcion: doc['descripcion'],
      tipo: 'Type',
      duracion: doc['ejecucion'],
      series: doc['serie'],
      pausas: doc['pausa'],
      repeticiones: doc['repeticion'],
      carga: doc['carga'],
      dia: doc['dia'] ?? ''         
    );
  }
}
