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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ActividadProvider() {
    // Listen for changes in the 'actividad' collection and notify listeners
    _firestore.collection('actividad').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }

  // Get the number of participants for a given activity
  Future<int> cantidadParticipantes(String actividadId) async {
    final querySnapshot = await _firestore
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: actividadId)
        .get();
    return querySnapshot.docs.length;
  }

  // Fetch activities for a given date
  Future<List<Actividad>> fetchActividades(DateTime fecha) async {
    String? ownerActividades = await prefs.getSubscripcion();
    try {
      final now = DateTime.now();
      DateTime start;
      DateTime end;

      // Determine start and end times for the specified date
      if (fecha.year == now.year &&
          fecha.month == now.month &&
          fecha.day == now.day) {
        start = now;
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else {
        start = DateTime(fecha.year, fecha.month, fecha.day, 0, 0);
        end = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);
      }

      // Fetch activities that match the owner ID and fall within the specified time range
      final querySnapshot = await _firestore
          .collection('actividad')
          .where('propietarioActividadId', isEqualTo: ownerActividades)
          .where('inicio', isLessThanOrEqualTo: end)
          .where('fin', isGreaterThanOrEqualTo: start)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Map the fetched activities to a list of Actividad objects
        final fetchedActividades = querySnapshot.docs.map((doc) async {
          final actividadData = doc.data();
          actividadData['actividadId'] = doc.id;
          actividadData['participantes'] = await cantidadParticipantes(doc.id);
          return Actividad.fromDocument(actividadData);
        }).toList();
        return await Future.wait(fetchedActividades);
      } else {
        return [];
      }
    } catch (e) {
      logger.d('Error fetching actividades: $e');
      return [];
    }
  }

  // Register a new activity
  Future<bool> registrarActividad(Map<String, dynamic> actividadData) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String nombre = actividadData['nombreActividad'];
    final String propietarioActividadId = actividadData['propietarioActividadId'];
    final String tipo = actividadData['tipo'];
    final cupos = int.tryParse(actividadData['cupos'].toString()) ?? 0;
    final DateTime inicio = actividadData['inicio'].toDate();
    final DateTime fin = actividadData['fin'].toDate();
    final List<int> diasRepeticion = List<int>.from(actividadData['dias']);
    const int duracionMeses = 1;

    // Calculo la fecha final basada en la duracion en meses
    DateTime now = DateTime.now();
    DateTime fechaFinal = DateTime(now.year, now.month + duracionMeses, now.day);

    if (diasRepeticion.isEmpty) {
      // Creo actividad unica
      await firestore.collection('actividad').add({
        'nombreActividad': nombre,
        'propietarioActividadId': propietarioActividadId,
        'tipo': tipo,
        'cupos': cupos,
        'inicio': DateTime(inicio.year, inicio.month, inicio.day, inicio.hour, inicio.minute),
        'fin': DateTime(fin.year, fin.month, fin.day, fin.hour, fin.minute),
        'duracionMeses': duracionMeses,
        'diasRepeticion': diasRepeticion,
      });
    } else {
      // Recorro desde la fecha de inicio hasta la fecha final
      DateTime fechaActual = inicio;

      while (fechaActual.isBefore(fechaFinal)) {
        // Verifico si el dia de la semana actual es uno de los seleccionados
        int diaDeLaSemana = fechaActual.weekday;
        if (diasRepeticion.contains(diaDeLaSemana)) {
          await firestore.collection('actividad').add({
            'nombreActividad': nombre,
            'propietarioActividadId': propietarioActividadId,
            'tipo': tipo,
            'cupos': cupos,
            'inicio': DateTime(fechaActual.year, fechaActual.month, fechaActual.day, inicio.hour, inicio.minute),
            'fin': DateTime(fechaActual.year, fechaActual.month, fechaActual.day, fin.hour, fin.minute),
            'duracionMeses': duracionMeses,
            'diasRepeticion': diasRepeticion,
          });
        }
        
        // Avanzo al siguiente dia
        fechaActual = fechaActual.add(Duration(days: 1));
      }
    }

    notifyListeners();
    return true;
  } on FirebaseException catch (e) {
    print('Error al registrar la actividad: ${e.message}');
    return false;
  }
}

  // Update an existing activity
  Future<bool> actualizarActividad(Map<String, dynamic> actividadData) async {
    try {
      String? documentId = actividadData['id'];

      if (documentId == null) {
        throw Exception('Missing document ID for update');
      }
      await _firestore
          .collection('actividad')
          .doc(documentId)
          .update(actividadData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      logger.d(e);
      return false;
    }
  }

  // Delete an activity and its participants
  Future<bool> eliminarActividad(String documentId) async {
    try {
      final docRef = _firestore.collection('actividad').doc(documentId);
      await docRef.delete();

      final querySnapshot = await _firestore
          .collection('actividadParticipante')
          .where('actividadId', isEqualTo: documentId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      logger.d(e);
      return false;
    }
  }

  // Check if a user is registered for a specific activity
  Future<bool> estaInscripto(String userId, String actividadId) async {
    final querySnapshot = await _firestore
        .collection('actividadParticipante')
        .where('actividadId', isEqualTo: actividadId)
        .where('participanteId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Unregister a user from an activity and update their membership
  Future<bool> desinscribirseActividad(
      BuildContext context, String userId, String actividadId) async {
    try {
      final membresiaSnapshot =
          await Provider.of<MembresiaProvider>(context, listen: false)
              .obtenerMembresiaActiva(userId);

      if (membresiaSnapshot == null) {
        return false;
      }

      var usuarioMembresiaId = membresiaSnapshot.id;

      await _firestore
          .collection('usuarioMembresia')
          .doc(usuarioMembresiaId)
          .update({'cuposRestantes': FieldValue.increment(1)});

      final querySnapshot = await _firestore
          .collection('actividadParticipante')
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
      logger.d(e);
      return false;
    }
  }

  // Register a user for an activity and update their membership
  Future<bool> anotarseActividad(
      BuildContext context, String userId, String actividadId) async {
    try {
      final activity =
          await _firestore.collection('actividad').doc(actividadId).get();
      final membresiaSnapshot =
          await Provider.of<MembresiaProvider>(context, listen: false)
              .obtenerMembresiaActiva(userId);

      if (membresiaSnapshot == null) {
        return false;
      }

      var usuarioMembresiaId = membresiaSnapshot.id;

      await _firestore
          .collection('usuarioMembresia')
          .doc(usuarioMembresiaId)
          .update({'cuposRestantes': FieldValue.increment(-1)});

      final participantData = {
        'actividadId': actividadId,
        'participanteId': userId,
      };
      await _firestore.collection('actividadParticipante').add(participantData);

      final data = activity.data();
      final inicio = data!['inicio'];
      NotificationService().scheduleNotification(
          'Comienzo de Actividad Cercano',
          'Su actividad ${data['nombreActividad']} comenzará pronto',
          inicio);
      notifyListeners();
      return true;
    } catch (e) {
      logger.d(e);
      return false;
    }
  }

  // Fetch activities for the logged-in participant
  Future<List<Actividad>> actividadesDeParticipante() async {
    final userId = await prefs.getUserId();
    try {
      QuerySnapshot participantActivitiesSnapshot = await _firestore
          .collection('actividadParticipante')
          .where('participanteId', isEqualTo: userId)
          .get();

      List<String> activityIds = participantActivitiesSnapshot.docs
          .map((doc) => doc['actividadId'] as String)
          .toList();

      List<Actividad> activities = [];

      for (String activityId in activityIds) {
        DocumentSnapshot activityDoc =
            await _firestore.collection('actividad').doc(activityId).get();
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
      logger.d(e);
      rethrow;
    }
  }
}
