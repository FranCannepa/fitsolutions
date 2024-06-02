class Week {
  String? id;
  int? numero;

  Week({required this.id, required this.numero});


  static Week fromDocument(String id, Map<String, dynamic> doc) {
    return Week(id: id, numero: doc['number']);
  }
}
