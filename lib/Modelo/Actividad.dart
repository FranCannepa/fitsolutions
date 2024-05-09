class Actividad {
  String id;
  int duracion;
  String nombre;
  String descripcion;
  DateTime horario;
  String profesor;
  int cupos;
  int inscritos;
  Actividad({
    required this.id,
    required this.duracion,
    required this.nombre,
    required this.descripcion,
    required this.horario,
    required this.profesor,
    required this.cupos,
    required this.inscritos,
  });
}
