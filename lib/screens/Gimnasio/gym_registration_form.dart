import 'dart:io';

//import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/CommonComponents/input_time_picker.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _crossStreetController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

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

  bool _validateHours() {
    for (String day in _openHours.keys) {
      TimeOfDay openTime = _openHours[day]!;
      TimeOfDay closeTime = _closeHours[day]!;
      if (openTime.hour > closeTime.hour ||
          (openTime.hour == closeTime.hour &&
              openTime.minute >= closeTime.minute)) {
        return false;
      }
    }
    return true;
  }

  void _submitForm(BuildContext context, GimnasioProvider provider) async {
    if (_formKey.currentState!.validate()) {
      if (!_validateHours()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'La hora de apertura debe ser antes de la hora de cierre.')),
        );
        return;
      }

      _formKey.currentState!.save();

      await _uploadLogo(context, provider);

      String address = _streetAddressController.text;
      if (_crossStreetController.text.isNotEmpty) {
        address += ' esquina ${_crossStreetController.text}';
      }

      String contact = _celularController.text;
      if (_telefonoController.text.isNotEmpty) {
        contact += ' / ${_telefonoController.text}';
      }

      await provider.registerGym(
        _nameController.text,
        address,
        contact,
        _openHours,
        _closeHours,
      );

      if (context.mounted) {
        widget.onSubmit();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información registrada exitosamente')),
        );
      }
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El formulario cuenta con errores verificar')),
        );
    }
  }

  String? _validateCrossStreet(String? value) {
    // Allow empty value for cross street
    if (value == null || value.isEmpty) {
      return null; // No error, value is valid
    }
    return null;
  }

  String? _validateApertura(TimeOfDay? value) {
    // Allow empty value for cross street
    for (var day in _openHours.keys) {
      if (_openHours[day] == null) {
        return 'Seleccionar una hora';
      }
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    // Allow empty value for phone number
    if (value == null || value.isEmpty) {
      return null; // No error, value is valid
    }
    if (RegExp(r'^\d{8}$').hasMatch(value)) {
      return null; // No error, value is valid
    } else {
      return 'Ingrese un número de teléfono uruguayo válido (8 dígitos)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final esPropietario = context.read<UserData>().esParticular();
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _pickImage(),
                child: Center(
                  child: _gymLogo != null
                      ? ClipOval(
                          child: Image.file(_gymLogo!,
                              height: 100, width: 100, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: const Center(child: Text('Agregar Logo')),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: esPropietario == true
                      ? 'Nombre Entrenador'
                      : 'Nombre Gimnasio',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return esPropietario == true
                        ? 'Ingrese el nombre del entrenador'
                        : 'Ingrese el nombre del gimnasio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _streetAddressController,
                decoration: const InputDecoration(
                  labelText: 'Calle y Numero',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la calle y número';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _crossStreetController,
                decoration: const InputDecoration(
                  labelText: 'Esquina',
                ),
                validator: _validateCrossStreet,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _celularController,
                decoration: const InputDecoration(
                  labelText: 'Celular',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de celular';
                  }
                  if (RegExp(r'^\d{9}$').hasMatch(value)) {
                    return null; // No error, value is valid
                  } else {
                    return 'Ingrese un número de teléfono uruguayo válido (9 dígitos)';
                  }
                },
              ),
              TextFormField(
                 keyboardType: TextInputType.number,
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                ),
                validator: _validatePhoneNumber,
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
                        child: InputTimePicker(
                            labelText: 'Apertura',
                            horaSeleccionada: _openHours[day],
                            onTimeSelected: (time) {
                              setState(() {
                                _openHours[day] = time;
                              });
                            },
                            validator: _validateApertura),
                      ),
                      const Text(' - '),
                      Expanded(
                        flex: 2,
                        child: InputTimePicker(
                          labelText: 'Cierre',
                          horaSeleccionada: _closeHours[day],
                          onTimeSelected: (time) {
                            setState(() {
                              _closeHours[day] = time;
                            });
                          },
                          validator: (time) {
                            if (_openHours[day] != null &&
                                (_closeHours[day]!.hour <
                                        _openHours[day]!.hour ||
                                    (_closeHours[day]!.hour ==
                                            _openHours[day]!.hour &&
                                        _closeHours[day]!.minute <=
                                            _openHours[day]!.minute))) {
                              return 'La hora de cierre debe ser después de la hora de apertura';
                            }
                            return null;
                          },
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
