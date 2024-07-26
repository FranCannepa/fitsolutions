import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/modelo/membresia_asignada.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MembresiaProvider extends ChangeNotifier {
  final prefs = SharedPrefsHelper();
  final Logger log = Logger();

  MembresiaProvider() {
    FirebaseFirestore.instance
        .collection('membresia')
        .snapshots()
        .listen((snapshot) {
      notifyListeners();
    });
    FirebaseFirestore.instance
        .collection('usuarioMembresia')
        .snapshots()
        .listen((snapshot) {
      notifyListeners();
    });
  }
  Future<List<Membresia>> getMembresiasOrigen() async {
    final String? origenMembresia = await prefs.getSubscripcion();
    if (origenMembresia != null && origenMembresia != '') {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('membresia')
            .where('origenMembresia', isEqualTo: origenMembresia)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final fetchedMembresias = querySnapshot.docs.map((doc) {
            final data = doc.data();
            data['membresiaId'] = doc.id;
            return Membresia.fromDocument(data);
          }).toList();
          return fetchedMembresias;
        } else {
          return [];
        }
      } catch (e) {
        log.e('Error fetching membresias: $e');
        return [];
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> getMembresiaDetails(String membresiaId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('membresia')
          .doc(membresiaId)
          .get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      log.e("Error al obtener los detalles de la membresía: $e");
      return null;
    }
  }

  Future<String?> getMembershipName(String membershipId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('membresia').doc(membershipId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data?['nombreMembresia'] as String?;
      } else {
        log.e("No se encontro membresia con ID: $membershipId");
        return null;
      }
    } catch (e) {
      log.e("Error fetching membresia: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOrigenMembresia(String documentId) async {
    try {
      final usuarioRef =
          FirebaseFirestore.instance.collection('usuario').doc(documentId);
      final usuarioSnapshot = await usuarioRef.get();

      if (usuarioSnapshot.exists) {
        final data = usuarioSnapshot.data()!;
        return {
          ...data,
          'origenTipo': 'Entrenador',
        };
      }
      final gimnasioRef =
          FirebaseFirestore.instance.collection('gimnasio').doc(documentId);
      final gimnasioSnapshot = await gimnasioRef.get();
      if (gimnasioSnapshot.exists) {
        final data = gimnasioSnapshot.data()!;
        final nombreOrigen = data['nombreGimnasio'];
        return {
          'nombreOrigen': nombreOrigen,
          'origenTipo': 'Gimnasio',
        };
      }
      return null;
    } catch (e) {
      log.e("Error fetching origen membership: $e");
      return null;
    }
  }

  Future<bool> registrarMembresia(Map<String, dynamic> membresiaData) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('membresia').doc();
      await docRef.set(membresiaData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      log.e(e);
      return false;
    } catch (e) {
      log.e(e);
      return false;
    }
  }

  //Ryan: aqui las credenciales son siempre las mismas por eso se guardan
  //en firestore para su uso
  Future<Map<String, String>> getKeys(String gimnasioId) async {
   /* final docSnapshot = await FirebaseFirestore.instance
        .collection('gimnasio')
        .doc(gimnasioId)
        .get();*/
    final col = FirebaseFirestore.instance.collection('mercadoPagoCredentials');
    QuerySnapshot querySnapshot = await col.limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> dataCred =
          documentSnapshot.data() as Map<String, dynamic>;

      /*if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final publicKey = data['publicKey'] as String;
        final accessToken = data['accessToken'] as String;*/
      return {
        'publicKey': dataCred['accessToken'],
        'accessToken': dataCred['accessToken']
      };
    } else {
      throw Exception("Gimnasio no encontrado");
    }
  }

  Future<bool> actualizarMembresia(
      Map<String, dynamic> updatedMembresiaData) async {
    try {
      final String? membresiaId =
          updatedMembresiaData.remove('origenMembresia');
      if (membresiaId == null) {
        throw Exception('Missing "membresiaId" field in updatedMembresiaData');
      }
      FirebaseFirestore.instance
          .collection('membresia')
          .doc(membresiaId)
          .update(updatedMembresiaData);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      log.e("Error updating document: ${e.message}");
      return false;
    } catch (e) {
      log.e("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }

  Future<bool> eliminarMembresia(String documentId) async {
    try {
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('membresia').doc(documentId);
      await docRef.delete();
      final usuarioMems = await db.collection('usuarioMembresia').get();
      for (var um in usuarioMems.docs) {
        final umData = um.data();
        if (umData['membresiaId'] == documentId) {
          await db.collection('usuarioMembresia').doc(um.id).delete();
        }
      }
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      log.e("Error deleting document: ${e.message}");
      return false;
    } catch (e) {
      log.e("An unexpected error occurred: ${e.toString()}");
      return false;
    }
  }

  Future<DocumentSnapshot?> obtenerMembresiaActiva(String usuarioId) async {
    try {
      final db = FirebaseFirestore.instance;
      var snapshot = await db
          .collection('usuarioMembresia')
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
      Logger().d('Error al obtener la membresía activa: $e');
    }
    return null;
  }

  Future<MembresiaAsignada?> obtenerInformacionMembresiaUser(
      String usuarioId) async {
    try {
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('usuarioMembresia')
          .where('usuarioId', isEqualTo: usuarioId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final usuarioMembresiaData = snapshot.docs.first.data();
        final membresiaId = usuarioMembresiaData['membresiaId'];

        final membresiaFirestore =
            await db.collection('membresia').doc(membresiaId).get();
        if (membresiaFirestore.exists) {
          final docData = membresiaFirestore.data();
          docData!['membresiaId'] = membresiaFirestore.id;

          Membresia membresiaInfo = Membresia.fromDocument(docData);

          return MembresiaAsignada.fromData(
              snapshot.docs.first.id, usuarioMembresiaData, membresiaInfo);
        }
        return null;
      }
      return null;
    } catch (e) {
      Logger().d('Error al obtener la membresía: $e');
    }
    return null;
  }

  Future<void> cambiarEstadoMembresia(bool estado, String id) async {
    try {
      final newState = estado ? 'activa' : 'inactiva';

      await FirebaseFirestore.instance
          .collection('usuarioMembresia')
          .doc(id)
          .update({'estado': newState});
      notifyListeners();
    } catch (e) {
      Logger().d('Error al cambiar estado: $e');
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
    // Check if a document with the same usuarioId and membresiaId already exists
    QuerySnapshot existingMembership = await FirebaseFirestore.instance
        .collection('usuarioMembresia')
        .where('usuarioId', isEqualTo: clienteId)
        .limit(1)
        .get();

    if (existingMembership.docs.isNotEmpty) {
      // Document already exists, handle accordingly
      for (var doc in existingMembership.docs) {
        if (doc['estado'] == 'activa') {
          throw Exception('Este usuario ya tiene una membresia activa');
        } else {
          final membresiaDocRef = await FirebaseFirestore.instance
              .collection('membresia')
              .doc(membresiaId)
              .get();
          final membresiaData = membresiaDocRef.data();
          await FirebaseFirestore.instance
              .collection('usuarioMembresia')
              .doc(doc.id)
              .update({
            'estado': 'activa',
            'membresiaId': membresiaId,
            'cuposRestantes': membresiaData!['cupos'],
            'fechaCompra': DateTime.now(),
            'fechaExpiracion': getNextMonth(DateTime.now()),
          });
          return true; // Indicating that the membership was updated
        }
      }
      return true;
    }

    final userDocRef = await FirebaseFirestore.instance
        .collection('usuario')
        .doc(clienteId)
        .get();
    final membresiaDocRef = await FirebaseFirestore.instance
        .collection('membresia')
        .doc(membresiaId)
        .get();
    final membresiaData = membresiaDocRef.data();

    final userMembershipData = {
      'cuposRestantes': membresiaData!['cupos'],
      'membresiaId': membresiaDocRef.id,
      'usuarioId': userDocRef.id,
      'estado': 'activa',
      'fechaCompra': DateTime.now(),
      'fechaExpiracion': getNextMonth(DateTime.now()),
    };

    await FirebaseFirestore.instance
        .collection('usuarioMembresia')
        .add(userMembershipData);

    return true;
  }
}
