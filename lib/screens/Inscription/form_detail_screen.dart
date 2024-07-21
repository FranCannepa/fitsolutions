import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/modelo/models.dart';
import '../../providers/inscription_provider.dart';

class FormDetailsScreen extends StatelessWidget {
  final String ownerId;
  final String userId;

  const FormDetailsScreen({super.key, required this.ownerId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final inscriptionProvider = context.watch<InscriptionProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: const Text(
              'Detalles de Inscripcion',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
        body: FutureBuilder<FormModel?>(
          future: inscriptionProvider.getFormData(ownerId, userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: NoDataError(message: 'El usuario no ha completado su formulario'));
            }
      
            FormModel formData = snapshot.data!;
      
            return Container(
              color: Colors.grey[200], // Background color for the screen
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildInfoCard('CI', formData.ci),
                    _buildInfoCard('Direccion',formData.direccion),
                    _buildInfoCard('Contacto',formData.celular),
                    _buildInfoCard('Fecha de Nacimiento', formData.fechaNacimiento),
                    _buildInfoCard('Sociedad', formData.sociedad),
                    _buildInfoCard('Emergencia', formData.emergencia),
                    _buildInfoCard('Lesiones', formData.lesiones),
                    _buildInfoCard('Número de Emergencia', formData.numeroEmergencia),
                    _buildObjectivesCard('Objetivos', formData.objetivos),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildObjectivesCard(String title, List<String> objectives) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 4.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            ...objectives.map((objective) {
              return CheckboxListTile(
                title: Text(objective),
                value: true,
                onChanged: (bool? value) {},
              );
            }),
          ],
        ),
      ),
    );
  }
}