import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../modelo/models.dart';

class ChartProvider extends ChangeNotifier {
  Logger log = Logger();
  final FirebaseFirestore _firebase;
  final SharedPrefsHelper prefs;

  ChartProvider(FirebaseFirestore? firestore, this.prefs)
      : _firebase = firestore ?? FirebaseFirestore.instance;


  Future<List<Actividad>> getAllActivities() async {
    final id = await prefs.getSubscripcion();
    QuerySnapshot snapshot = await _firebase
        .collection('actividad')
        .where('propietarioActividadId', isEqualTo: id)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final list = snapshot.docs.map((doc) async {
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

  Future<List<Actividad>> getAllActivitiesByDate(
      {required int month, required int year}) async {
    try {
      final id = await prefs.getSubscripcion();
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth =
          DateTime(year, month + 1, 1).subtract(const Duration(days: 1));

      QuerySnapshot snapshot = await _firebase
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: id)
          .where('fin', isGreaterThanOrEqualTo: startOfMonth)
          .where('inicio', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) async {
          final actividadData = doc.data() as Map<String, dynamic>;
          actividadData['actividadId'] = doc.id;
          final actividad = Actividad.fromDocument(actividadData);
          actividad.participantes = await getParticipantsCount(doc.id);
          return actividad;
        }).toList();
        return Future.wait(list);
      }
      return [];
    } catch (e) {
      Logger().e(e);
      return [];
    }
  }


  Future<int> getParticipantsCount(String activityId) async {
    QuerySnapshot snapshot = await _firebase
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: activityId)
        .get();
    Logger().d('$activityId ${snapshot.size}');
    return snapshot.size;
  }


  Future<List<UsuarioBasico>> getAllParticipants() async {
    final ownerId = await prefs.getSubscripcion();

    QuerySnapshot activitySnapshot = await _firebase
        .collection('actividad')
        .where('propietarioActividadId', isEqualTo: ownerId)
        .get();

    Set<String> activityIds =
        activitySnapshot.docs.map((doc) => doc.id).toSet();

    if (activityIds.isEmpty) {
      return [];
    }

    QuerySnapshot participantSnapshot = await _firebase
        .collection('actividadParticipante')
        .where('actividadId', whereIn: activityIds.toList())
        .get();

    List<UsuarioBasico> participants = [];
    Set<String> userIds = participantSnapshot.docs
        .map((doc) => doc['participanteId'] as String)
        .toSet();

    for (var userId in userIds) {
      DocumentSnapshot userDoc =
          await _firebase.collection('usuario').doc(userId).get();
      if (userDoc.exists) {
        participants.add(UsuarioBasico.fromDocument(
            userDoc.id, userDoc.data() as Map<String, dynamic>));
      }
    }

    return participants;
  }
}
