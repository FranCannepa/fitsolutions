import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class GimnasioProvider with ChangeNotifier {
  final Logger log = Logger();
  final SharedPrefsHelper prefs = SharedPrefsHelper();

  final FirebaseFirestore _firebase;

  GimnasioProvider(FirebaseFirestore? firestore)
      : _firebase = firestore ?? FirebaseFirestore.instance {
    _firebase.collection('gimnasio').snapshots().listen((snapshot) {
      notifyListeners();
    });
    _firebase.collection('trainerInfo').snapshots().listen((snapshot) {
      notifyListeners();
    });
  }

  Map<String, dynamic>? gymData;
  File? gymLogo;
  String? gymLogoUrl;
  bool showGymForm = false;

  Future<Gimnasio?> getGym() async {
    final prefs = SharedPrefsHelper();
    final esEntrenador = await prefs.esEntrenador();
    String? collection = 'gimnasio';
    if (esEntrenador) {
      collection = 'trainerInfo';
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('propietarioId', isEqualTo: await prefs.getUserId())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();
      Gimnasio? gym = Gimnasio.fromFirestore(docSnapshot.id, data);
      return gym;
    } else {
      return null;
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      gymLogo = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> uploadLogo(File? gymLogo) async {
    if (gymLogo == null) return;

    try {
      String fileName = path.basename(gymLogo.path);
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('gym_logos')
          .child(fileName);
      await ref.putFile(gymLogo);
      gymLogoUrl = await ref.getDownloadURL();
      log.d('Logo uploaded. URL: $gymLogoUrl');
      notifyListeners();
    } catch (e) {
      log.e('Error uploading logo: $e');
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hours = timeOfDay.hour.toString().padLeft(2, '0');
    final minutes = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.hour < 12 ? 'AM' : 'PM';
    final formattedHour = hours.startsWith('0') ? hours.substring(1) : hours;
    return '$formattedHour:$minutes $period';
  }

  Future<void> registerGym(
    String name,
    String address,
    String contact,
    Map<String, TimeOfDay> openHours,
    Map<String, TimeOfDay> closeHours,
  ) async {
    final userId = await prefs.getUserId();
    try {
      final gymData = {
        'nombreGimnasio': name,
        'direccion': address,
        'contacto': contact,
        'propietarioId': userId,
        'logoUrl': gymLogoUrl ?? '',
        'horario': {
          'Monday-Friday': {
            'open': formatTimeOfDay(openHours['Lunes - Viernes']!),
            'close': formatTimeOfDay(closeHours['Lunes - Viernes']!),
          },
          'Saturday': {
            'open': formatTimeOfDay(openHours['Sabado']!),
            'close': formatTimeOfDay(closeHours['Sabado']!),
          },
          'Sunday': {
            'open': formatTimeOfDay(openHours['Domingo']!),
            'close': formatTimeOfDay(closeHours['Domingo']!),
          },
        }
      };
      final esEntrenador = await prefs.esEntrenador();
      String? collection = 'gimnasio';
      if (esEntrenador) {
        collection = 'trainerInfo';
      }
      final docRef = await _firebase.collection(collection).add(gymData);
      prefs.setSubscripcion(docRef.id);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void toggleGymForm() {
    showGymForm = !showGymForm;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getClientesGym(String gymId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('usuario')
          .where('asociadoId', isEqualTo: gymId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> usuarios = [];
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          data['usuarioId'] = doc.id;
          usuarios.add(data);
        }
        return usuarios;
      } else {
        return [];
      }
    } catch (e) {
      log.d("Error getting usuarios data: $e");
      return [];
    }
  }
}
