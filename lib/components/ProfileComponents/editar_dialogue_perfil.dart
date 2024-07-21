import 'dart:io';
import 'package:fitsolutions/components/CommonComponents/input_date_picker.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/submit_button.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onClose;
  const EditProfileDialog(
      {super.key, required this.userData, required this.onClose});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthdateController;
  late DateTime _fechaActividad;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['nombreCompleto']);
    _heightController =
        TextEditingController(text: widget.userData['altura'].toString());
    _weightController =
        TextEditingController(text: widget.userData['peso'].toString());
    _birthdateController =
        TextEditingController(text: widget.userData['fechaNacimiento']);
    _fechaActividad = DateTime.parse(widget.userData['fechaNacimiento']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  String? validateBirthDate(DateTime? birthDate) {
    final today = DateTime.now();
    if (_fechaActividad.isAfter(today)) {
      return 'La fecha de nacimiento no puede ser en el futuro.';
    }

    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showSuccessModal(String mensaje, ResultType resultado) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    ).then((_) {
      if (resultado == ResultType.success) {
        widget.onClose();
      }
    });
  }

  void _saveChanges() async {
    final provider = context.read<UserData>();
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await provider.uploadImage(_imageFile!);
      }
      Map<String, dynamic> updatedData = {
        'nombreCompleto': _nameController.text,
        'altura': int.parse(_heightController.text),
        'peso': double.parse(_weightController.text),
        'fechaNacimiento':
            '${_fechaActividad.year}-${_fechaActividad.month.toString().padLeft(2, '0')}-${_fechaActividad.day.toString().padLeft(2, '0')}',
        'profilePic': imageUrl ?? widget.userData['profilePic'],
      };

      final result = await provider.perfilUpdate(updatedData);
      if (result) {
        _showSuccessModal("Perfil Actualizado", ResultType.success);
      } else {
        _showSuccessModal("Error al actualizar perfil", ResultType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider<Object>
                              : (widget.userData['profilePic'] != null &&
                                      widget.userData['profilePic'].isNotEmpty
                                  ? NetworkImage(widget.userData['profilePic'])
                                      as ImageProvider<Object>
                                  : null),
                          child: _imageFile == null &&
                                  (widget.userData['profilePic'] == null ||
                                      widget.userData['profilePic'].isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: const Text('Cambiar foto de perfil'),
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Nombre Completo'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      TextFormField(
                          controller: _heightController,
                          decoration:
                              const InputDecoration(labelText: 'Altura'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El campo no puede ser vacio';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Debe ser un número válido';
                            }
                            if (int.parse(value) <= 0) {
                              return 'El número no puede ser negativo, o cero';
                            }
                            return null;
                          }),
                      TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(labelText: 'Peso'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El campo no puede ser vacio';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Debe ser un número válido';
                            }
                            if (double.tryParse(value)! <= 0) {
                              return 'El número no puede ser negativo, o cero';
                            }
                            return null;
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text('Fecha de Nacimiento'),
                          InputDatePicker(
                              labelText: "Fecha",
                              fechaSeleccionada: _fechaActividad,
                              onDateSelected: (date) {
                                setState(() {
                                  _fechaActividad = date;
                                });
                              },
                              validator: validateBirthDate),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SubmitButton(
                        text: "Guardar",
                        onPressed: () async {
                          _saveChanges();
                        },
                      )
                    ]),
                  )),
            ]))));
  }
}
