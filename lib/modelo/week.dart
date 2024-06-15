import 'package:fitsolutions/modelo/ejercicio.dart';

class Week {
  String? id;
  int? numero;
  final List<Ejercicio> ejercicios;
  
  Week({required this.id, required this.numero, required this.ejercicios});


  static Week fromDocument(String id, Map<String, dynamic> doc, List<Ejercicio> ejercicios) {
    return Week(id: id, numero: doc['number'],ejercicios: ejercicios);
  }

  List<Ejercicio> getExercisesByDay(String day) {
    return ejercicios.where((ejercicio) => ejercicio.dia == day).toList();
  }

}
