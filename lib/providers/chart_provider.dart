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

  // Fetch all participants for a specific activity (amount)
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
    final ownerId = await prefs.getSubscripcion();
    // Step 1: Fetch activities where propietarioId is equal to gymId
    QuerySnapshot activitySnapshot = await _firebase
        .collection('actividad')
        .where('propietarioActividadId', isEqualTo: ownerId)
        .get();

    Set<String> activityIds =
        activitySnapshot.docs.map((doc) => doc.id).toSet();

    if (activityIds.isEmpty) {
      return [];
    }
    // Step 2: Fetch participants for the activities
    QuerySnapshot participantSnapshot = await _firebase
        .collection('actividadParticipante')
        .where('actividadId', whereIn: activityIds.toList())
        .get();

    List<UsuarioBasico> participants = [];
    Set<String> userIds = participantSnapshot.docs
        .map((doc) => doc['participanteId'] as String)
        .toSet();
    // Step 3: Fetch user data for the participants
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
