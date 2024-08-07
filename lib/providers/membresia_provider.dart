import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/membresia_asignada.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MembresiaProvider extends ChangeNotifier {
  final FirebaseFirestore _firebase;
  final SharedPrefsHelper _prefs;
  final Logger _log = Logger();

  MembresiaProvider(this._firebase, this._prefs) {
    _firebase.collection('membresia').snapshots().listen((_) {
      notifyListeners();
    });
    _firebase.collection('usuarioMembresia').snapshots().listen((_) {
      notifyListeners();
    });
  }

  Future<List<Membresia>> getMembresiasOrigen() async {
    final String? origenMembresia = await _prefs.getSubscripcion();
    if (origenMembresia != null && origenMembresia.isNotEmpty) {
      try {
        final querySnapshot = await _firebase
            .collection('membresia')
            .where('origenMembresia', isEqualTo: origenMembresia)
            .get();
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['membresiaId'] = doc.id;
          return Membresia.fromDocument(data);
        }).toList();
      } catch (e) {
        _log.e('Error fetching membresias: $e');
        return [];
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> getMembresiaDetails(String membresiaId) async {
    try {
      final docSnapshot = await _firebase.collection('membresia').doc(membresiaId).get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      _log.e("Error al obtener los detalles de la membresía: $e");
      return null;
    }
  }

  Future<String?> getMembershipName(String membershipId) async {
    try {
      final docSnapshot = await _firebase.collection('membresia').doc(membershipId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['nombreMembresia'] as String?;
      } else {
        _log.e("No se encontro membresia con ID: $membershipId");
        return null;
      }
    } catch (e) {
      _log.e("Error fetching membresia: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOrigenMembresia(String documentId) async {
    try {
      final usuarioSnapshot = await _firebase.collection('usuario').doc(documentId).get();
      if (usuarioSnapshot.exists) {
        return {...usuarioSnapshot.data()!, 'origenTipo': 'Entrenador'};
      }

      final gimnasioSnapshot = await _firebase.collection('gimnasio').doc(documentId).get();
      if (gimnasioSnapshot.exists) {
        return {'nombreOrigen': gimnasioSnapshot.data()!['nombreGimnasio'], 'origenTipo': 'Gimnasio'};
      }
      return null;
    } catch (e) {
      _log.e("Error fetching origen membership: $e");
      return null;
    }
  }

  Future<bool> registrarMembresia(Map<String, dynamic> membresiaData) async {
    try {
      await _firebase.collection('membresia').add(membresiaData);
      notifyListeners();
      return true;
    } catch (e) {
      _log.e("Error registering membership: $e");
      return false;
    }
  }

  Future<Map<String, String>> getKeys(String gimnasioId) async {
    try {
      final col = _firebase.collection('mercadoPagoCredentials');
      final querySnapshot = await col.limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        final dataCred = querySnapshot.docs.first.data();
        return {
          'publicKey': dataCred['publicKey'],
          'accessToken': dataCred['accessToken']
        };
      } else {
        throw Exception("Gimnasio no encontrado");
      }
    } catch (e) {
      _log.e("Error fetching keys: $e");
      throw Exception("Error fetching keys: $e");
    }
  }

  Future<bool> actualizarMembresia(Map<String, dynamic> updatedMembresiaData) async {
    try {
      final String? membresiaId = updatedMembresiaData.remove('membresiaId');
      if (membresiaId == null) {
        throw Exception('Missing "membresiaId" field in updatedMembresiaData');
      }
      await _firebase.collection('membresia').doc(membresiaId).update(updatedMembresiaData);
      notifyListeners();
      return true;
    } catch (e) {
      _log.e("Error updating membership: $e");
      return false;
    }
  }

  Future<bool> eliminarMembresia(String documentId) async {
    final db = _firebase;
    try {
      final batch = db.batch();
      final docRef = db.collection('membresia').doc(documentId);
      batch.delete(docRef);

      final usuarioMems = await db.collection('usuarioMembresia').where('membresiaId', isEqualTo: documentId).get();
      for (var um in usuarioMems.docs) {
        batch.delete(db.collection('usuarioMembresia').doc(um.id));
      }

      await batch.commit();
      notifyListeners();
      return true;
    } catch (e) {
      _log.e("Error deleting membership: $e");
      return false;
    }
  }

  Future<DocumentSnapshot?> obtenerMembresiaActiva(String usuarioId) async {
    try {
      final snapshot = await _firebase.collection('usuarioMembresia')
          .where('usuarioId', isEqualTo: usuarioId)
          .where('fechaExpiracion', isGreaterThan: DateTime.now())
          .where('cuposRestantes', isGreaterThan: 0)
          .orderBy('fechaExpiracion', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      }
    } catch (e) {
      _log.e('Error al obtener la membresía activa: $e');
    }
    return null;
  }

  Future<MembresiaAsignada?> obtenerInformacionMembresiaUser(String usuarioId) async {
    try {
      final snapshot = await _firebase.collection('usuarioMembresia')
          .where('usuarioId', isEqualTo: usuarioId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final usuarioMembresiaData = snapshot.docs.first.data();
        final membresiaId = usuarioMembresiaData['membresiaId'];

        final membresiaFirestore = await _firebase.collection('membresia').doc(membresiaId).get();
        if (membresiaFirestore.exists) {
          final docData = membresiaFirestore.data()!..['membresiaId'] = membresiaFirestore.id;
          final membresiaInfo = Membresia.fromDocument(docData);

          return MembresiaAsignada.fromData(snapshot.docs.first.id, usuarioMembresiaData, membresiaInfo);
        }
      }
      return null;
    } catch (e) {
      _log.e('Error al obtener la membresía: $e');
      return null;
    }
  }

  Future<void> cambiarEstadoMembresia(bool estado, String id) async {
    try {
      final newState = estado ? 'activa' : 'inactiva';
      await _firebase.collection('usuarioMembresia').doc(id).update({'estado': newState});
      notifyListeners();
    } catch (e) {
      _log.e('Error al cambiar estado: $e');
    }
  }

  DateTime getNextMonth(DateTime currentDate) {
    int nextMonth = currentDate.month + 1;
    int nextYear = currentDate.year;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear += 1;
    }

    return DateTime(nextYear, nextMonth, currentDate.day);
  }

  Future<bool> asignarMembresia(String membresiaId, String clienteId) async {
    try {
      final existingMembership = await _firebase.collection('usuarioMembresia')
          .where('usuarioId', isEqualTo: clienteId)
          .limit(1)
          .get();

      if (existingMembership.docs.isNotEmpty) {
        for (var doc in existingMembership.docs) {
          if (doc['estado'] == 'activa') {
            throw Exception('Este usuario ya tiene una membresia activa');
          } else {
            await _firebase.collection('usuarioMembresia').doc(doc.id).update({'estado': 'inactiva'});
          }
        }
      }

      final newMembership = {
        'usuarioId': clienteId,
        'membresiaId': membresiaId,
        'estado': 'activa',
        'fechaAsignacion': DateTime.now(),
        'fechaExpiracion': getNextMonth(DateTime.now()),
        'cuposRestantes': (await _firebase.collection('membresia').doc(membresiaId).get()).data()!['numeroEntradas']
      };

      await _firebase.collection('usuarioMembresia').add(newMembership);
      notifyListeners();
      return true;
    } catch (e) {
      _log.e('Error assigning membership: $e');
      return false;
    }
  }
}

