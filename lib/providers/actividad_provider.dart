import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Modelo/Actividad.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';

class ActividadProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  final logger = Logger();

  ActividadProvider() {
    FirebaseFirestore.instance
        .collection('actividad')
        .snapshots()
        .listen((snapshot) {
      notifyListeners();
    });
  }

  Future<int> cantidadParticipantes(String actividadId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: actividadId)
        .get();
    return querySnapshot.docs.length;
  }

  getCantidadParticipantes(String actividadId) async {
    return await cantidadParticipantes(actividadId);
  }

  Future<List<Actividad>> fetchActividades(DateTime fecha) async {
    String? ownerActividades = await prefs.getSubscripcion();
    try {
      final now = DateTime.now();
      DateTime start;
      DateTime end;

      if (fecha.year == now.year &&
          fecha.month == now.month &&
          fecha.day == now.day) {
        start = now;
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else {
        start = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
        end = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: ownerActividades)
          .where('inicio', isLessThanOrEqualTo: end)
          .where('fin', isGreaterThanOrEqualTo: start)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final fetchedActividades = querySnapshot.docs.map((doc) async {
          final actividadData = doc.data();
          actividadData['actividadId'] = doc.id;
          actividadData['participantes'] = await cantidadParticipantes(doc.id);
          final actividad = Actividad.fromDocument(actividadData);
          return actividad;
        }).toList();
        final completedActividades = await Future.wait(fetchedActividades);
        return completedActividades;
      } else {
        return [];
      }
    } catch (e) {
      logger.d('Error fetching actividades: $e');
      return [];
    }
  }

  Future<bool> registrarActividad(Map<String, dynamic> actividadData) async {
    try {
      await FirebaseFirestore.instance
          .collection('actividad')
          .add(actividadData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      Logger().d(e);
      rethrow;
    }
  }

  Future<bool> actualizarActividad(Map<String, dynamic> actividadData) async {
    try {
      String? documentId = actividadData['id'];

      if (documentId == null) {
        throw Exception('Missing document ID for update');
      }
      await FirebaseFirestore.instance
          .collection('actividad')
          .doc(documentId)
          .update(actividadData);

      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      Logger().d(e);
      rethrow;
    } catch (e) {
      Logger().d(e);
      return false;
    }
  }

  Future<bool> eliminarActividad(String documentId) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('actividad').doc(documentId);
      await docRef.delete();

      final querySnapshot = await db
          .collection('actividadParticipante')
          .where('actividadId', isEqualTo: documentId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      Logger().d(e);
      return false;
    } catch (e) {
      Logger().d(e);
      return false;
    }
  }

  Future<bool> estaInscripto(String userId, String actividadId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: actividadId)
        .where('participanteId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> desinscribirseActividad(
      BuildContext context, String userId, String actividadId) async {
    try {
      //obtengo la membresia actual del usuario
      final membresiaSnapshot =
          await Provider.of<MembresiaProvider>(context, listen: false)
              .obtenerMembresiaActiva(userId);

      if (membresiaSnapshot == null) {
        return false;
      }

      //id de la membresia
      var usuarioMembresiaId = membresiaSnapshot.id;

      //incremento un cupo
      await FirebaseFirestore.instance
          .collection('usuarioMembresia')
          .doc(usuarioMembresiaId)
          .update({'cuposRestantes': FieldValue.increment(1)});

      final collectionRef =
          FirebaseFirestore.instance.collection('actividadParticipante');
      final querySnapshot = await collectionRef
          .where('actividadId', isEqualTo: actividadId)
          .where('participanteId', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Logger().d(e);
      return false;
    }
  }

  Future<bool> anotarseActividad(
      BuildContext context, String userId, String actividadId) async {
    try {
      final activity = await FirebaseFirestore.instance
          .collection('actividad')
          .doc(actividadId)
          .get();
      //obtengo la membresia actual del usuario
      final membresiaSnapshot =
          await Provider.of<MembresiaProvider>(context, listen: false)
              .obtenerMembresiaActiva(userId);

      if (membresiaSnapshot == null) {
        return false;
      }

      //id de la membresia
      var usuarioMembresiaId = membresiaSnapshot.id;

      //decremento un cupo
      await FirebaseFirestore.instance
          .collection('usuarioMembresia')
          .doc(usuarioMembresiaId)
          .update({'cuposRestantes': FieldValue.increment(-1)});

      //registro al usuario en la actividad
      final collectionRef =
          FirebaseFirestore.instance.collection('actividadParticipante');
      final participantData = {
        'actividadId': actividadId,
        'participanteId': userId,
      };
      await collectionRef.add(participantData);

      final data = activity.data();
      final inicio = data!['inicio'];
      NotificationService().scheduleNotification(
          'Comienzo de Actividad Cercano',
          'Su actividad ${data['nombreActividad']} comezara pronto',
          inicio);
      notifyListeners();
      return true;
    } catch (e) {
      Logger().d(e);
      return false;
    }
  }

  Future<List<Actividad>> actividadesDeParticipante() async {
    final userId = await prefs.getUserId();
    try {
      QuerySnapshot participantActivitiesSnapshot = await FirebaseFirestore
          .instance
          .collection('actividadParticipante')
          .where('participanteId', isEqualTo: userId)
          .get();

      List<String> activityIds = participantActivitiesSnapshot.docs
          .map((doc) => doc['actividadId'] as String)
          .toList();

      List<Actividad> activities = [];

      for (String activityId in activityIds) {
        DocumentSnapshot activityDoc = await FirebaseFirestore.instance
            .collection('actividad')
            .doc(activityId)
            .get();
        if (activityDoc.exists) {
          final actividadData = activityDoc.data() as Map<String, dynamic>;
          actividadData['actividadId'] = activityDoc.id;
          final actividad = Actividad.fromDocument(actividadData);
          actividad.participantes = await cantidadParticipantes(activityId);
          activities.add(actividad);
        }
      }
      return activities;
    } catch (e) {
      rethrow;
    }
  }
}
