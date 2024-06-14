import 'package:fitsolutions/modelo/models.dart';

class Plan{
  String planId;
  String name;
  String description;
  Map<String,dynamic> weight;
  Map<String,dynamic> height;
  List<Ejercicio> ejercicios = [];
  final List<Week> weeks;
  //
   

  Plan({
    required this.planId,
    required this.name,
    required this.description,
    required this.weight,
    required this.height,
    required this.weeks,
  });


  Map<String, Object?> toDocument(){
    return {
      'planId' : planId,
      'name' : name,
      'description': description,
      'weight': weight,
      'height': height,
    };
  }

  static Plan fromDocument(String id, Map<String,dynamic> doc,List<Week> weeks){
    return Plan(
      planId: id,
      name: doc['name'],
      description: doc['description'],
      weight: doc['weight'],
      height: doc['height'],
      weeks: weeks
    );
  }

  void addWeek(Week newWeek){
    weeks.add(newWeek);
  }
  void removeWeek(){
    weeks.removeLast();
  }

  int weekCount(){
    return weeks.length;
  }

  String lastWeek(){
    return weeks.last.id!;
  }

  String idFromWeek(int number){
    return weeks.elementAt(number).id!;
  }

  List<Ejercicio> ejerciciosDelDia(String weekId, String diaId){
    Week week = weeks.firstWhere((week) => week.id == weekId);
    return week.getExercisesByDay(diaId);
  }

}