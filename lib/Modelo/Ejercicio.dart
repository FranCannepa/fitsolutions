class Ejercicio {
  String nombre;
  String descripcion;
  String tipo; // "Cardio", "Fuerza", "Flexibilidad"
  int duracion; // En minutos

  Ejercicio({
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.duracion,
  });
}
