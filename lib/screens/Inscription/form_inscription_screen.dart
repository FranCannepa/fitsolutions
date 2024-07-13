import 'package:fitsolutions/Utilities/ci_input_formatter.dart';
import 'package:fitsolutions/Utilities/utilities.dart';
import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../providers/inscription_provider.dart';

class FormInscriptionScreen extends StatefulWidget {
  const FormInscriptionScreen({super.key});

  @override
  State<FormInscriptionScreen> createState() => _FormInscriptionScreenState();
}

class _FormInscriptionScreenState extends State<FormInscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _userId;
  bool _loading = true;
  bool _isReadOnly = false; // Add this line

  final List<String> _selectedObjectives = [];

  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _sociedadController = TextEditingController();
  final TextEditingController _emergenciaController = TextEditingController();
  final TextEditingController _lesionesController = TextEditingController();
  final TextEditingController _numeroEmergenciaController =
      TextEditingController(); // New field for selected objectives
  DateTime _selectedDate = DateTime.now();

  final List<String> _objectives = [
    'Entrenar en grupo',
    'Bajar % de grasa',
    'Aumentar masa muscular',
    'Recuperación de lesión',
    'Mejorar rendimiento deportivo',
    'Mejorar salud',
    'Mejorar estética',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _ciController.dispose();
    _fechaNacimientoController.dispose();
    _sociedadController.dispose();
    _emergenciaController.dispose();
    _lesionesController.dispose();
    _numeroEmergenciaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = SharedPrefsHelper();
    String? userId = await prefs.getUserId();
    setState(() {
      _userId = userId;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Logger log = Logger();
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Formulario de Inscripcion')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final inscriptionProvider = context.watch<InscriptionProvider>();

    return Scaffold(
                  appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white, // Set the back arrow color here
              ),
              backgroundColor: Colors.black,
              title: const Text(
                'Formulario de Inscripcion',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,  
                ),
              )),
        body: FutureBuilder<FormModel?>(
            future: inscriptionProvider.getFormByUserId(_userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                log.e(snapshot.data);
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: NoDataError(message: 'No hay formulario disponible'));
              }

              var form = snapshot.data!;
              // Initialize text controllers with form data if available
              if (form.ci != '') {
                _ciController.text = form.ci;
                _fechaNacimientoController.text = form.fechaNacimiento;
                _sociedadController.text = form.sociedad;
                _emergenciaController.text = form.emergencia;
                _lesionesController.text = form.lesiones;
                _numeroEmergenciaController.text = form.numeroEmergencia;
                _selectedObjectives.addAll(form.objetivos);
                _isReadOnly =form.readOnly; 
              }

              return Form(
                key: _formKey,
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'CI'),
                    controller: _ciController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CIInputFormatter()
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe completar este campo';
                      }
                      return null;
                    },
                    enabled: !_isReadOnly, // Set enabled property
                  ),
                  InkWell(
                    onTap: _isReadOnly
                        ? null
                        : () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: Theme.of(context)
                                        .primaryColor, // Head background
                                    colorScheme: ColorScheme.light(
                                        primary:
                                            Theme.of(context).primaryColor),
                                    buttonTheme: const ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                                _fechaNacimientoController.text =
                                    "${picked.year}-${picked.month}-${picked.day}";
                              });
                            }
                          },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _fechaNacimientoController,
                        decoration: const InputDecoration(
                            labelText: 'Fecha de Nacimiento'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Debe completar este campo';
                          }
                          return null;
                        },
                        enabled: !_isReadOnly, // Set enabled property
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Sociedad'),
                    controller: _sociedadController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe completar este campo';
                      }
                      return null;
                    },
                    enabled: !_isReadOnly, // Set enabled property
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Emergencia'),
                    controller: _emergenciaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe completar este campo';
                      }
                      return null;
                    },
                    enabled: !_isReadOnly, // Set enabled property
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Lesiones'),
                    controller: _lesionesController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe completar este campo';
                      }
                      return null;
                    },
                    enabled: !_isReadOnly, // Set enabled property
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Número de Emergencia'),
                    controller: _numeroEmergenciaController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe completar este campo';
                      }
                      return null;
                    },
                    enabled: !_isReadOnly, // Set enabled property
                  ),
                  // Checkboxes for objectives
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Objetivos a alcanzar con nuestro servicio:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._objectives.map((objective) {
                    return CheckboxListTile(
                      title: Text(objective),
                      value: _selectedObjectives.contains(objective),
                      onChanged: _isReadOnly
                          ? null
                          : (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedObjectives.add(objective);
                                } else {
                                  _selectedObjectives.remove(objective);
                                }
                              });
                            },
                    );
                  }),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isReadOnly
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              Map<String, dynamic> formData = {
                                'ci': _ciController.text,
                                'fechaNacimiento':
                                    _fechaNacimientoController.text,
                                'sociedad': _sociedadController.text,
                                'emergencia': _emergenciaController.text,
                                'lesiones': _lesionesController.text,
                                'numeroEmergencia':
                                    _numeroEmergenciaController.text,
                                'objetivos': _selectedObjectives,
                                'readOnly':
                                    true, // Set readOnly to true on form submission
                              };
                              await inscriptionProvider.submitFormData(
                                  form.formId, formData);
                              if (context.mounted) {
                                setState(() {
                                  _isReadOnly = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Form submitted')));
                              }
                            }
                          },
                    child: const Text('Completar'),
                  ),
                ]),
              );
            }));
  }
}
