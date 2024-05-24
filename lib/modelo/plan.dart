class Plan{
  String planId;
  String name;

  Plan({
    required this.planId,
    required this.name
  });

  Plan copyWith({
    String? planId,
    String? name
  }){
    return Plan(planId: planId ?? this.planId,name: name ?? this.name);
  }

  Map<String, Object?> toDocument(){
    return {
      'planId' : planId,
      'name' : name
    };
  }

  static Plan fromDocument(String id, Map<String,dynamic> doc){
    return Plan(
      planId: id,
      name: doc['name']
    );
  }
}