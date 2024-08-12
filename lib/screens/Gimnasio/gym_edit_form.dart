import 'dart:io';
import 'package:fitsolutions/Components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/Utilities/shared_prefs_helper.dart';
import 'package:fitsolutions/components/CommonComponents/input_round_fields.dart';
import 'package:fitsolutions/components/CommonComponents/input_time_picker.dart';
import 'package:fitsolutions/modelo/Gimnasio.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GymModificationForm extends StatefulWidget {
  const GymModificationForm({
    super.key,
  });

  @override
  State<GymModificationForm> createState() => _GymModificationFormState();
}

class _GymModificationFormState extends State<GymModificationForm> {
  final _formKey = GlobalKey<FormState>();
  final Logger log = Logger();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _crossStreetController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? logo;
  bool? esEntrenador;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    esTrainer();
    _fetchGymData();
  }

  Future<void> esTrainer() async {
    final prefs = SharedPrefsHelper();
    bool trainerStatus = await prefs.esEntrenador();
    setState(() {
      esEntrenador = trainerStatus;
    });
  }

  Future<void> _fetchGymData() async {
    setState(() {
      _isLoading = true;
    });
    final provider = context.read<GimnasioProvider>();
    Gimnasio? gymData = await provider.getGym();
    if (gymData != null) {
      // Assuming you have a method to get gym data
      final addressParts = splitAddress(gymData.direccion);
      final contactParts = splitContact(gymData.contacto);
      setState(() {
        logo = gymData.logoUrl;
        _nameController.text = gymData.nombreGimnasio;
        _streetAddressController.text = addressParts['street'].toString();
        _crossStreetController.text = addressParts['crossStreet'].toString();
        _celularController.text = contactParts['cell'].toString();
        _telefonoController.text = contactParts['phone'].toString();
        _openHours = parseOpenHours(gymData.horario);
        _closeHours = parseCloseHours(gymData.horario);
        _isLoading = false;
      });
    }
  }

  Map<String, TimeOfDay> _openHours = {};

  Map<String, TimeOfDay> _closeHours = {};

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadLogo(
      BuildContext context, GimnasioProvider provider) async {
    if (_imageFile != null) {
      await provider.uploadLogo(_imageFile!);
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

  Map<String, String> splitAddress(String direccion) {
    final parts = direccion.split(' esquina ');
    return {
      'street': parts[0],
      'crossStreet': parts.length > 1 ? parts[1] : '',
    };
  }

  Map<String, String> splitContact(String contacto) {
    final parts = contacto.split(' / ');
    return {
      'cell': parts[0],
      'phone': parts.length > 1 ? parts[1] : '',
    };
  }

  Map<String, TimeOfDay> parseOpenHours(
      Map<String, Map<String, String>> horario) {
    final openHours = <String, TimeOfDay>{};

    horario.forEach((day, times) {
      final openTimeString = times['open']?.trim(); // Trim any whitespace
      if (openTimeString != null && openTimeString.isNotEmpty) {
        try {
          final openTime = _parseTime(openTimeString);
          openHours[day] = openTime;
        } catch (e) {
          log.e('Error parsing open time for $day: $e');
          // Handle or log the error as needed
        }
      }
    });

    return openHours;
  }

  TimeOfDay _parseTime(String timeString) {
    final format =
        RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
    final match = format.firstMatch(timeString);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);

      return TimeOfDay(hour: hour, minute: minute);
    } else {
      throw FormatException('Invalid time format: $timeString');
    }
  }

  Map<String, TimeOfDay> parseCloseHours(
      Map<String, Map<String, String>> horario) {
    final closeHours = <String, TimeOfDay>{};

    horario.forEach((day, times) {
      final closeTimeString = times['close']?.trim(); // Trim any whitespace
      if (closeTimeString != null && closeTimeString.isNotEmpty) {
        try {
          final closeTime = _parseTime(closeTimeString);
          closeHours[day] = closeTime;
        } catch (e) {
          log.e('Error parsing close time for $day: $e');
          // Handle or log the error as needed
        }
      }
    });

    return closeHours;
  }

  Future<void> _submitForm(
      BuildContext context, GimnasioProvider provider) async {
    if (_formKey.currentState!.validate()) {
      if (!_validateHours()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'La hora de apertura debe ser antes de la hora de cierre.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

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
      
      await provider.updateGym(
        _nameController.text,
        address,
        contact,
        logo!,
        _openHours,
        _closeHours,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Información modificada exitosamente')),
        );
        Navigator.pop(context);
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El formulario cuenta con errores verificar')),
      );
    }
  }

  String? _validateCrossStreet(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return null;
  }

  String? _validateApertura(TimeOfDay? value) {
    for (var day in _openHours.keys) {
      if (_openHours[day] == null) {
        return 'Seleccionar una hora';
      }
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (RegExp(r'^\d{8}$').hasMatch(value)) {
      return null;
    } else {
      return 'Ingrese un número de teléfono uruguayo válido (8 dígitos)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final esPropietario = context.read<UserData>().esParticular();
    final provider = context.read<GimnasioProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modificar Informacion',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (logo != null && logo != ''
                                ? NetworkImage(logo!)
                                : null) as ImageProvider<Object>?,
                        child: _imageFile == null &&
                                (logo == null || logo!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RoundedInputField(
                      controller: _nameController,
                      
                        labelText: esPropietario == true
                            ? 'Nombre Entrenador'
                            : 'Nombre Gimnasio',

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return esPropietario == true
                              ? 'Ingrese el nombre del entrenador'
                              : 'Ingrese el nombre del gimnasio';
                        }
                        return null;
                      },
                    ),
                    RoundedInputField(
                      controller: _streetAddressController,
                    
                        labelText: 'Calle y Numero',

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la calle y número';
                        }
                        return null;
                      },
                    ),
                    RoundedInputField(
                      controller: _crossStreetController,

                        labelText: 'Esquina',
                      validator: _validateCrossStreet,
                    ),
                    RoundedInputField(
                      keyboardType: TextInputType.number,
                      controller: _celularController,

                        labelText: 'Celular',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el número de celular';
                        }
                        if (RegExp(r'^\d{9}$').hasMatch(value)) {
                          return null;
                        } else {
                          return 'Ingrese un número de teléfono uruguayo válido (9 dígitos)';
                        }
                      },
                    ),
                    RoundedInputField(
                      keyboardType: TextInputType.number,
                      controller: _telefonoController,
                      
                        labelText: 'Teléfono',
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
                        onPressed: () => _submitForm(context, provider),
                        text: "Modificar",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
