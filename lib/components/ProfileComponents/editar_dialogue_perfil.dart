import 'dart:io';

import 'package:fitsolutions/providers/userData.dart';
import 'package:fitsolutions/screens/rutina_basico/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileDialog({super.key, required this.userData});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthdateController;
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
    _birthdateController = TextEditingController(
        text: widget.userData['fechaNacimiento'].toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveChanges() async{
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
        'fechaNacimiento': _birthdateController.text,
        'profilePic': imageUrl ?? widget.userData['profilePic'],
      };

      provider.perfilUpdate(updatedData);
      Navigator.pop(context);
    }
  }

 @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider<Object>
                      : (widget.userData['profilePic'] != null &&
                              widget.userData['profilePic'].isNotEmpty
                          ? NetworkImage(widget.userData['profilePic']) as ImageProvider<Object>
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
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Altura'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async{
            showDialog(context: context, builder: (BuildContext context) {
              return ConfirmDialog(
                        title: 'Editar Perfil',
                        content: '¿Desea Editar su Perfil?',
                        onConfirm: () async {
                          _saveChanges();
                        },
                        parentKey: null);
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
