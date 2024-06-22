import 'dart:io';

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
    'Monday-Friday': const TimeOfDay(hour: 9, minute: 0),
    'Saturday': const TimeOfDay(hour: 9, minute: 0),
    'Sunday': const TimeOfDay(hour: 9, minute: 0),
  };

  final Map<String, TimeOfDay> _closeHours = {
    'Monday-Friday': const TimeOfDay(hour: 22, minute: 0),
    'Saturday': const TimeOfDay(hour: 22, minute: 0),
    'Sunday': const TimeOfDay(hour: 22, minute: 0),
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
        widget.onSubmit(); // Call the callback to notify parent widget
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gym registered successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration:  InputDecoration(labelText: esEntrenador == true
                    ? 'Trainer Name'
                    : 'Gym Name',),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return esEntrenador == true
                      ? 'Please enter the trainer name'
                      : 'Please enter the gym name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: esEntrenador == true
                    ? 'Trainer Address'
                    : 'Gym Address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return esEntrenador == true
                      ? 'Please enter the trainer address'
                      : 'Please enter the gym address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: esEntrenador == true
                    ? 'Trainer Contact Info (Phone/Cell)'
                    : 'Gym Contact Info (Phone/Cell)',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return esEntrenador == true
                      ? 'Please enter the trainer contact information'
                      : 'Please enter the gym contact information';
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
                      child: const Center(child: Text('Tap to upload logo')),
                    ),
            ),
            const SizedBox(height: 16),
            const Text('Open Hours:'),
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
              child: ElevatedButton(
                onPressed: () => _submitForm(context, widget.provider),
                child: esEntrenador == true ? const Text('Register Trainer Info') : const Text('Register Gym'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
