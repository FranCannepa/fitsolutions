import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/input_roundFields.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Modelo/UserData.dart';
import 'package:fitsolutions/Utilities/SharedPrefsHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GimnasioForm extends StatefulWidget {
  const GimnasioForm({super.key});
  @override
  _GimnasioFormState createState() => _GimnasioFormState();
}

class _GimnasioFormState extends State<GimnasioForm> {
  final _gymNameController = TextEditingController();
  final _gymAddressController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  late Map<String, dynamic> gymData = {};

  Map<String, dynamic> collectGymData() {
    return {
      'nombreGimnasio': _gymNameController.text,
      'direccion': _gymAddressController.text,
      'apertura': _openingTimeController.text,
      'clausura': _closingTimeController.text
    };
  }

  Future<void> registerGym(Map<String, dynamic> gymData) async {
    final userProvider = context.read<UserData>();
    final prefs = SharedPrefsHelper();
    try {
      gymData['propietarioId'] = await prefs.getDocId();
      print(gymData);
      final docRef =
          await FirebaseFirestore.instance.collection('usuario').add(gymData);
      userProvider.updateCurrentGym(docRef.id);
    } on FirebaseException catch (e) {
      print(e.code);
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Row(
          children: [
            Expanded(
              child: RoundedInputField(
                labelText: 'Horario Apertura (24hrs)',
                controller: _openingTimeController,
                keyboardType: TextInputType.number,
                validator: (value) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RoundedInputField(
                labelText: 'Horario Cierre (24hrs)',
                controller: _closingTimeController,
                keyboardType: TextInputType.number,
                validator: (value) {},
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
