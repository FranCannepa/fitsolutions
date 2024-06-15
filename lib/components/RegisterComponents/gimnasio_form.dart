import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GimnasioForm extends StatefulWidget {
  final Function refresh;
  const GimnasioForm({super.key, required this.refresh});
  @override
  State<GimnasioForm> createState() => _GimnasioFormState();
}

class _GimnasioFormState extends State<GimnasioForm> {
  final _gymNameController = TextEditingController();
  final _gymAddressController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _telefonoController = TextEditingController();
  late Map<String, dynamic> gymData = {};

  Map<String, dynamic> collectGymData() {
    return {
      'nombreGimnasio': _gymNameController.text,
      'direccion': _gymAddressController.text,
      'apertura': _openingTimeController.text,
      'clausura': _closingTimeController.text,
      'contacto': _telefonoController.text
    };
  }

  Future<void> registerGym(Map<String, dynamic> gymData) async {
    final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    Logger log = Logger();
    try {
      gymData['propietarioId'] = await prefs.getUserId();
      final docRef =
          await FirebaseFirestore.instance.collection('gimnasio').add(gymData);
      userProvider.updateCurrentGym(docRef.id);
      widget.refresh();
    } on FirebaseException catch (e) {
      log.d(e.code);
      log.d(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTitle(title: "Registro Gimnasio"),
        RoundedInputField(
          labelText: 'Nombre del Gimnasio',
          controller: _gymNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese el nombre del gimnasio';
            }
            return null;
          },
        ),
        RoundedInputField(
          labelText: 'Dirección del Gimnasio',
          controller: _gymAddressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la dirección del gimnasio';
            }
            return null;
          },
        ),
        RoundedInputField(
          labelText: 'Telefono/Celular',
          controller: _telefonoController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese un numero de contacto';
            }
            return null;
          },
        ),
        const ScreenSubTitle(text: "Horarios"),
        Row(
          children: [
            Expanded(
              child: RoundedInputField(
                labelText: 'Apertura',
                controller: _openingTimeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
            ),
            Expanded(
              child: RoundedInputField(
                labelText: 'Cierre',
                controller: _closingTimeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return null;
                },
              ),
            ),
          ],
        ),
        SubmitButton(
          text: "Registrar",
          onPressed: () {
            gymData = collectGymData();
            registerGym(gymData);
          },
        )
      ],
    );
  }
}
