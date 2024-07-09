import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../modelo/models.dart';

class ChartProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase;
  final prefs = SharedPrefsHelper();

  ChartProvider(FirebaseFirestore? firestore)
      : _firebase = firestore ?? FirebaseFirestore.instance;

  // Fetch all activities
  Future<List<Actividad>> getAllActivities() async {
    final id = await prefs.getSubscripcion();
    QuerySnapshot snapshot = await _firebase.collection('actividad').where('propietarioActividadId',isEqualTo: id).get();
    if(snapshot.docs.isNotEmpty){
      final list = snapshot.docs.map((doc) async{
        final actividadData = doc.data() as Map<String, dynamic>;
        actividadData['actividadId'] = doc.id;
        final actividad = Actividad.fromDocument(actividadData);
        actividad.participantes = await getParticipantsCount(doc.id);
        return actividad;
      }).toList();
      return Future.wait(list);
    }
    return [];
  }

  // Fetch all participants for a specific activity
  Future<int> getParticipantsCount(String activityId) async {
    QuerySnapshot snapshot = await _firebase
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: activityId)
        .get();
    Logger().d('$activityId ${snapshot.size}');
    return snapshot.size;
  }

  // Fetch all participants details
  Future<List<UsuarioBasico>> getAllParticipants() async {
    QuerySnapshot snapshot =
        await _firebase.collection('actividadParticipante').get();
    List<UsuarioBasico> participants = [];
    for (var doc in snapshot.docs) {
      DocumentSnapshot userDoc =
          await _firebase.collection('usuario').doc(doc['participanteId']).get();
      participants.add(UsuarioBasico.fromDocument(
          userDoc.id, userDoc.data() as Map<String, dynamic>));
    }
    return participants;
  }
}
