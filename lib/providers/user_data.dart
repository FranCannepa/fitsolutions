import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';

class UserData extends ChangeNotifier {
  String nombreCompleto = '';
  String tipo = '';
  String userId = '';
  String fechaNacimiento = '';
  int altura = 0;
  double peso = 0;
  String email = '';
  String photoUrl = '';
  String gimnasioId = '';
  String asociadoId = '';
  late String calendarioId = '';
  late String membresiaId = '';
  late String entrenadorId = '';
  String? gimnasioIdPropietario = '';
  late String origenAdministrador = '';

  final prefs = SharedPrefsHelper();
  Logger log = Logger();

  get context => null;

  Future<void> initializeData() async {
    final prefs = SharedPrefsHelper();
    Logger log = Logger();
    String? userEmail = await prefs.getEmail();
    if (userEmail != null) {
      final userData = await getUserData(userEmail);
      final userTipo = userData?['tipo'];
      if (userTipo == "Basico") {
        await dataFormBasic(userData);
      } else if (userTipo == "Propietario") {
        await dataFormPropietario(userData);
      } else {
        await dataFormParticular(userData);
      }
    } else {
      log.d("EMPTY EMAIL!");
    }
    notifyListeners();
  }

  Future<String?> getUserId() async {
    final String? userId = await SharedPrefsHelper().getUserId();
    return userId;
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('usuario')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      data['userId'] = docSnapshot.id;
      return data;
    } else {
      return {};
    }
  }

  Future<String?> getUserNameById(String userId) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuario').doc(userId);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        return data?['nombreCompleto'] as String?;
      } else {
        log.d("No se encontro usuario con ID: $userId");
        return null;
      }
    } catch (e) {
      log.d("Error fetching nombre usuario: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final String? userId = await SharedPrefsHelper().getUserId();
    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuario').doc(userId);
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        data!['id'] = userId;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      log.d("Error getting user: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMembresias(
      String origenMembresia) async {
    final collection = FirebaseFirestore.instance.collection('membresia');
    final querySnapshot = await collection
        .where('origenMembresia', isEqualTo: origenMembresia)
        .get();
    final membersias = querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['membresiaId'] = doc.id;
      notifyListeners();
      return data;
    }).toList();

    return membersias;
  }

  Future<Membresia?> getMembresia() async {
    if (membresiaId == '') {
      return null;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('membresia')
        .doc(membresiaId)
        .get();
    if (querySnapshot.exists) {
      final data = querySnapshot.data();
      data?['membresiaId'] = querySnapshot.id;
      notifyListeners();
      return Membresia.fromDocument(data!);
    } else {
      return null;
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

  Future<void> updateMembresiaId(String membresiaId) async {
    final String? userId = await getUserId();
    if (userId != null) {
      // Obtengo la membresia
      final membresiaProvider =
          MembresiaProvider(FirebaseFirestore.instance, prefs);
      final membresiaData =
          await membresiaProvider.getMembresiaDetails(membresiaId);

      if (membresiaData != null) {
        // Mantengo todavia el asignamiento de la membresiaId al usuario por las dudas
        await FirebaseFirestore.instance
            .collection('usuario')
            .doc(userId)
            .update({
          'membresiaId': membresiaId,
        });
        this.membresiaId = membresiaId;

        // Calculo la fecha de expiracion y los cupos restantes
        DateTime fechaCompra = DateTime.now();
        DateTime fechaExpiracion = getNextMonth(DateTime.now());
        int cuposRestantes = membresiaData['cupos'] ?? 0;

        //Verificar si existe
        final doc = await FirebaseFirestore.instance
            .collection('usuarioMembresia')
            .where('usuarioId', isEqualTo: userId)
            .limit(1)
            .get();

        if (doc.docs.isNotEmpty) {
          final docId = doc.docs.first.id;
          await FirebaseFirestore.instance
              .collection('usuarioMembresia')
              .doc(docId)
              .set({
            'membresiaId':membresiaId,
            'fechaCompra': fechaCompra,
            'fechaExpiracion': fechaExpiracion,
            'cuposRestantes': cuposRestantes,
            'estado': 'activa',
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance.collection('usuarioMembresia').add({
            'usuarioId': userId,
            'membresiaId': membresiaId,
            'fechaCompra': fechaCompra,
            'fechaExpiracion': fechaExpiracion,
            'cuposRestantes': cuposRestantes,
            'estado': 'activa',
          });
        }
        // Agrego la membresia a la tabla usuarioMembresia

        //notifyListeners();
      } else {
        log.d(
            "Membresía no encontrada o datos incompletos para ID: $membresiaId");
      }
    } else {
      log.d("No se pudo actualizar la membresía o el ID de usuario es nulo");
    }
  }

  bool esPropietarioGym() {
    return gimnasioIdPropietario != '';
  }

  Future<bool> rutasBasico() async {
    return await prefs.getUserTipo() == "Basico";
  }

  bool esBasico() {
    return tipo == "Basico";
  }

  bool esPropietario() {
    return tipo == "Propietario";
  }

  bool esParticular() {
    return tipo == "Particular";
  }

  void updateCurrentGym(String gymId) {
    gimnasioId = gymId;
    notifyListeners();
  }

  void updateuserId(String newuserId) {
    userId = newuserId;
    notifyListeners();
  }

  Future<bool?> tieneSub() async {
    final bool sub = await prefs.tieneSub();
    return sub;
  }

  bool tieneMembresia() {
    return membresiaId != '';
  }

  void updateFechaNacimiento(String newFechaNacimiento) {
    fechaNacimiento = newFechaNacimiento;
    notifyListeners();
  }

  Future<void> dataFormBasic(Map<String, dynamic>? userData) async {
    String? usuarioId = userData?['userId'];
    if (usuarioId != null) {
      userId = usuarioId;
    } else {
      userId = await prefs.getUserId() as String;
    }
    nombreCompleto = userData?['nombreCompleto'] ?? '';
    fechaNacimiento = userData?['fechaNacimiento'] ?? '';
    origenAdministrador = userData?['asociadoId'] ?? '';
    entrenadorId = userData?['entrenadorSub'] ?? '';
    membresiaId = userData?['membresiaId'] ?? '';
    tipo = "Basico";
    altura = userData?['altura'] ?? 0;
    peso = userData?['peso'] ?? 0;
    notifyListeners();
  }

  Future<void> dataFormPropietario(Map<String, dynamic>? userData) async {
    userId = userData?['userId'] ?? await prefs.getUserId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Propietario';
    origenAdministrador = (await getGimnasioPropietario(userId)) ?? '';
    notifyListeners();
  }

  Future<void> dataFormParticular(Map<String, dynamic>? userData) async {
    userId = userData?['userId'] ?? await prefs.getUserId();
    nombreCompleto = userData?['nombreCompleto'];
    tipo = 'Particular';
    origenAdministrador = (await prefs.getTrainerInfo(userId)) ?? '';
    notifyListeners();
  }

  void firstLogin(User user) {
    if (user.email!.isNotEmpty) {
      final prefs = SharedPrefsHelper();
      email = user.email as String;
      photoUrl = user.photoURL != null ? user.photoURL as String : '';
      prefs.setEmail(email);
    }
    //notifyListeners();
  }

  void updateUserData(Map<String, dynamic>? userData) {
    userId = userData?['userId'] ?? '';
    nombreCompleto = userData?['nombre_completo'] ?? '';
    tipo = userData?['tipo'] ?? '';
    notifyListeners();
  }

  Future<String?> getGimnasioPropietario(String propietarioId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('gimnasio')
          .where('propietarioId', isEqualTo: propietarioId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        notifyListeners();
        return docSnapshot.id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> perfilUpdate(Map<String, dynamic> userData) async {
    try {
      final userId = await prefs.getUserId();
      await FirebaseFirestore.instance
          .collection('usuario')
          .doc(userId)
          .update(userData);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pics/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
