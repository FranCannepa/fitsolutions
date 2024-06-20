import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';
import 'package:fitsolutions/modelo/models.dart';

class EvaluationDetailsScreen extends StatelessWidget {
  final String gymId;
  final String userId;

  const EvaluationDetailsScreen(
      {super.key, required this.gymId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation Details'),
      ),
      body: FutureBuilder<EvaluationModel?>(
        future: Provider.of<InscriptionProvider>(context, listen: false)
            .getEvaluationData(gymId, userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No evaluation data found'));
          }

          EvaluationModel evaluation = snapshot.data!;
          return Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildEvaluationRow(
                      'Sentadilla Pie', evaluation.sentadillaPie),
                  _buildEvaluationRow(
                      'Sentadilla Tobillos', evaluation.sentadillaTobillos),
                  _buildEvaluationRow(
                      'Sentadilla Rodilla', evaluation.sentadillaRodilla),
                  _buildEvaluationRow(
                      'Sentadilla Cadera', evaluation.sentadillaCadera),
                  _buildEvaluationRow(
                      'Sentadilla Tronco', evaluation.sentadillaTronco),
                  _buildEvaluationRow(
                      'Sentadilla Hombro', evaluation.sentadillaHombro),
                  _buildSideBySideRow(
                      'Tocar Puntas',
                      evaluation.tocarPuntasPieDerecho,
                      evaluation.tocarPuntasPieIzquierdo),
                  _buildSideBySideRow(
                      'Dorsiflexión Tobillo',
                      evaluation.dorsiflexionTobilloDerecho,
                      evaluation.dorsiflexionTobilloIzquierdo),
                  _buildSideBySideRow(
                      'EAPR', evaluation.eaprDerecho, evaluation.eaprIzquierdo),
                  _buildSideBySideRow('Hombro', evaluation.hombroDerecho,
                      evaluation.hombroIzquierdo),
                  _buildSideBySideRow(
                      'PMR', evaluation.pmrDerecho, evaluation.pmrIzquierdo),
                  _buildEvaluationRow(
                      'Plancha Frontal', evaluation.planchaFrontal),
                  _buildEvaluationRow('Lagartija', evaluation.lagartija),
                  _buildEvaluationRow(
                      'Sentadilla Excéntrica', evaluation.sentadillaExcentrica),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEvaluationRow(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
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
          value,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildSideBySideRow(
      String title, String rightValue, String leftValue) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Izquierdo: $leftValue',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Derecho: $rightValue',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
