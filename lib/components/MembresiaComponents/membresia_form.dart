import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class MembresiaForm extends StatefulWidget {
  final Function refresh;
  const MembresiaForm({super.key, required this.refresh});

  @override
  State<MembresiaForm> createState() => _MembresiaFormState();
}

class _MembresiaFormState extends State<MembresiaForm> {
  final _nombreMembresia = TextEditingController();
  final _costoMembresia = TextEditingController();
  final _descripcionMembresia = TextEditingController();
  late Map<String, dynamic> membresiaData = {};
  bool showMembresiaForm = false;

  Map<String, dynamic> collectMembresiaData() {
    return {
      'nombreMembresia': _nombreMembresia.text,
      'costo': _costoMembresia.text,
      'descripcion': _descripcionMembresia.text,
    };
  }

  Future<void> registrarMembresia() async {
    final userProvider = context.read<UserData>();
    final gymId = userProvider.gimnasioId;
    Logger log = Logger();
    membresiaData['gimnasioId'] = gymId;
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('membresia')
          .add(membresiaData);
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
        RoundedInputField(
          labelText: 'Nombre',
          controller: _nombreMembresia,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese el nombre de la membresia';
            }
            return null;
          },
        ),
        RoundedInputField(
          labelText: 'Costo',
          controller: _costoMembresia,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la dirección del gimnasio';
            }
            return null;
          },
        ),
        RoundedInputField(
          labelText: 'Descripcion',
          controller: _descripcionMembresia,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la dirección del gimnasio';
            }
            return null;
          },
        ),
        SubmitButton(
          text: "Registrar",
          onPressed: () {
            membresiaData = collectMembresiaData();
            registrarMembresia();
          },
        ),
      ],
    );
  }
}
