class FormModel {
  final String formId;
  final String userId;
  final String direccion;
  final String celular;
  final String ci;
  final String fechaNacimiento;
  final String sociedad;
  final String emergencia;
  final String lesiones;
  final String numeroEmergencia;
  final List<String> objetivos; // New field for objectives
  final bool readOnly; // Add this line// Add other necessary fields

  FormModel({
    required this.formId,
    required this.direccion,
    required this.celular,
    required this.userId,
    required this.ci,
    required this.fechaNacimiento,
    required this.sociedad,
    required this.emergencia,
    required this.lesiones,
    required this.numeroEmergencia,
    required this.objetivos,
    required this.readOnly,
  });

  static FormModel fromDocument(String formId, Map<String, dynamic> doc) {
    Map<String, dynamic> formData = doc['formData'] ?? {};
    return FormModel(
      formId: formId,
      userId: doc['basicUserId'] ?? '',
      direccion: formData['direccion'] ?? '',
      celular: formData['celular'] ?? '',
      ci: formData['ci'] ?? '',
      fechaNacimiento: formData['fechaNacimiento'] ?? '',
      sociedad: formData['sociedad'] ?? '',
      emergencia: formData['emergencia'] ?? '',
      lesiones: formData['lesiones'] ?? '',
      numeroEmergencia: formData['numeroEmergencia'] ?? '',
      objetivos: List<String>.from(formData['objetivos'] ?? []),
      readOnly: doc['readOnly'] ?? false, // Parse objectives
    );
  }

  static Map<String, dynamic> toDocument(FormModel form) {
    return {
      'userId': form.userId,
      'ci': form.ci,
      'fechaNacimiento': form.fechaNacimiento,
      'sociedad': form.sociedad,
      'emergencia': form.emergencia,
      'lesiones': form.lesiones,
      'numeroEmergencia': form.numeroEmergencia,
      'objetivos': form.objetivos,
      'readOnly': form.readOnly, // Save objectives
    };
  }
}
