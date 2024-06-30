import 'dart:developer';
import 'dart:io';

import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GymRegistrationForm extends StatefulWidget {
  final GimnasioProvider provider;
  final VoidCallback onSubmit;
  const GymRegistrationForm(
      {super.key, required this.provider, required this.onSubmit});

  @override
  State<GymRegistrationForm> createState() => _GymRegistrationFormState();
}

class _GymRegistrationFormState extends State<GymRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  File? _gymLogo;
  bool? esEntrenador;

  @override
  void initState() {
    super.initState();
    esTrainer();
  }

  Future<void> esTrainer() async {
    final prefs = SharedPrefsHelper();
    bool trainerStatus = await prefs.esEntrenador();
    setState(() {
      esEntrenador = trainerStatus;
    });
  }

  final Map<String, TimeOfDay> _openHours = {
    'Lunes - Viernes': const TimeOfDay(hour: 9, minute: 0),
    'Sabado': const TimeOfDay(hour: 9, minute: 0),
    'Domingo': const TimeOfDay(hour: 9, minute: 0),
  };

  final Map<String, TimeOfDay> _closeHours = {
    'Lunes - Viernes': const TimeOfDay(hour: 22, minute: 0),
    'Sabado': const TimeOfDay(hour: 22, minute: 0),
    'Domingo': const TimeOfDay(hour: 22, minute: 0),
  };

  Future<void> _selectTime(
      BuildContext context, String day, bool isOpen) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? _openHours[day]! : _closeHours[day]!,
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _openHours[day] = picked;
        } else {
          _closeHours[day] = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _gymLogo = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadLogo(
      BuildContext context, GimnasioProvider provider) async {
    if (_gymLogo != null) {
      await provider.uploadLogo(_gymLogo!);
    }
  }

  void _submitForm(BuildContext context, GimnasioProvider provider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _uploadLogo(context, provider);

      await provider.registerGym(
        _nameController.text,
        _addressController.text,
        _contactController.text,
        _openHours,
        _closeHours,
      );
      if (context.mounted) {
        widget.onSubmit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ginasio registriado exitosamente')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: esEntrenador == true
                    ? 'Nombre Entrenador'
                    : 'Nombre Gimnasio',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return esEntrenador == true
                      ? 'Ingrese el nombre del entrenador'
                      : 'Ingrese el nombre del gimnasio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: esEntrenador == true
                    ? 'Direccion Entrenador'
                    : 'Direccion Gimnasio',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return esEntrenador == true
                      ? 'Ingrese la direccion del entrenador'
                      : 'Ingrese la direccion del gimnasio';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: esEntrenador == true
                    ? 'Contacto Entrenador (Telefono/Celular)'
                    : 'Contacto Gimnasio (Telefono/Celular)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la informacion de contacto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickImage(),
              child: _gymLogo != null
                  ? Image.file(_gymLogo!, height: 100)
                  : Container(
                      color: Colors.grey[200],
                      height: 100,
                      child: const Center(child: Text('Agregar Logo')),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Horarios'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _openHours.keys.map((day) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(day),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () => _selectTime(context, day, true),
                        child: Text(_openHours[day]!.format(context)),
                      ),
                    ),
                    const Text(' - '),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () => _selectTime(context, day, false),
                        child: Text(_closeHours[day]!.format(context)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Center(
                child: SubmitButton(
              onPressed: () => _submitForm(context, widget.provider),
              text: "Registrar",
            )),
          ],
        ),
      ),
    ));
  }
}
