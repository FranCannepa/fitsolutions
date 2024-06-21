class EvaluationModel {
  String sentadillaPie = '';
  String sentadillaTobillos = '';
  String sentadillaRodilla = '';
  String sentadillaCadera = '';
  String sentadillaTronco = '';
  String sentadillaHombro = '';

  String tocarPuntasPieDerecho = '';
  String tocarPuntasPieIzquierdo = '';

  String dorsiflexionTobilloDerecho = '';
  String dorsiflexionTobilloIzquierdo = '';

  String eaprDerecho = '';
  String eaprIzquierdo = '';

  String hombroDerecho = '';
  String hombroIzquierdo = '';

  String pmrDerecho = '';
  String pmrIzquierdo = '';

  String planchaFrontal = '';
  String lagartija = '';
  String sentadillaExcentrica = '';

  EvaluationModel();

  static EvaluationModel fromDocument(Map<String, dynamic> doc) {
    return EvaluationModel()
      ..sentadillaPie = doc['sentadillaPie'] ?? ''
      ..sentadillaTobillos = doc['sentadillaTobillos'] ?? ''
      ..sentadillaRodilla = doc['sentadillaRodilla'] ?? ''
      ..sentadillaCadera = doc['sentadillaCadera'] ?? ''
      ..sentadillaTronco = doc['sentadillaTronco'] ?? ''
      ..sentadillaHombro = doc['sentadillaHombro'] ?? ''
      ..tocarPuntasPieDerecho = doc['tocarPuntasPieDerecho'] ?? ''
      ..tocarPuntasPieIzquierdo = doc['tocarPuntasPieIzquierdo'] ?? ''
      ..dorsiflexionTobilloDerecho = doc['dorsiflexionTobilloDerecho'] ?? ''
      ..dorsiflexionTobilloIzquierdo = doc['dorsiflexionTobilloIzquierdo'] ?? ''
      ..eaprDerecho = doc['eaprDerecho'] ?? ''
      ..eaprIzquierdo = doc['eaprIzquierdo'] ?? ''
      ..hombroDerecho = doc['hombroDerecho'] ?? ''
      ..hombroIzquierdo = doc['hombroIzquierdo'] ?? ''
      ..pmrDerecho = doc['pmrDerecho'] ?? ''
      ..pmrIzquierdo = doc['pmrIzquierdo'] ?? ''
      ..planchaFrontal = doc['planchaFrontal'] ?? ''
      ..lagartija = doc['lagartija'] ?? ''
      ..sentadillaExcentrica = doc['sentadillaExcentrica'] ?? '';
  }
}