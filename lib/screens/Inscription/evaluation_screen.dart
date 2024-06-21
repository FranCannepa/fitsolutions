import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitsolutions/modelo/evaluation_model.dart';
import 'package:fitsolutions/providers/inscription_provider.dart';

class EvaluationFormScreen extends StatefulWidget {
  final String gymId;
  final String userId;

  const EvaluationFormScreen({
    super.key,
    required this.gymId,
    required this.userId,
  });

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EvaluationModel _evaluationModel = EvaluationModel();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final inscriptionProvider = context.read<InscriptionProvider>();

      try {
        await inscriptionProvider.submitEvaluationForm(
          gymId: widget.gymId,
          userId: widget.userId,
          evaluationModel: _evaluationModel,
        );
        await inscriptionProvider.moveDocumentToSubscribed(
            widget.gymId, widget.userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluation submitted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit evaluation')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de movimiento y fuerza'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEvaluationCard(
                  title: 'Sentadilla over head (OFD)',
                  fields: [
                    _buildTextFormField('Pie', (value) => _evaluationModel.sentadillaPie = value),
                    _buildTextFormField('Tobillos', (value) => _evaluationModel.sentadillaTobillos = value),
                    _buildTextFormField('Rodilla', (value) => _evaluationModel.sentadillaRodilla = value),
                    _buildTextFormField('Cadera', (value) => _evaluationModel.sentadillaCadera = value),
                    _buildTextFormField('Tronco', (value) => _evaluationModel.sentadillaTronco = value),
                    _buildTextFormField('Hombro', (value) => _evaluationModel.sentadillaHombro = value),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Tocar puntas de pies',
                  fields: [
                    _buildSideBySideFields('Izquierdo', 'Derecho', 
                      (value) => _evaluationModel.tocarPuntasPieIzquierdo = value,
                      (value) => _evaluationModel.tocarPuntasPieDerecho = value,
                    ),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Dorsiflexión de tobillo',
                  fields: [
                    _buildSideBySideFields('Izquierdo', 'Derecho', 

                      (value) => _evaluationModel.dorsiflexionTobilloIzquierdo = value,
                                            (value) => _evaluationModel.dorsiflexionTobilloDerecho = value,
                    ),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'EAPR (Flex cadera)',
                  fields: [
                    _buildSideBySideFields('Izquierdo', 'Derecho', 

                      (value) => _evaluationModel.eaprIzquierdo = value,
                                            (value) => _evaluationModel.eaprDerecho = value,
                    ),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Hombro (asimétrico)',
                  fields: [
                    _buildSideBySideFields('Izquierdo', 'Derecho', 

                      (value) => _evaluationModel.hombroIzquierdo = value,                      
                      (value) => _evaluationModel.hombroDerecho = value,
                    ),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'PMR',
                  fields: [
                    _buildSideBySideFields('Izquierdo', 'Derecho', 

                      (value) => _evaluationModel.pmrIzquierdo = value,
                                            (value) => _evaluationModel.pmrDerecho = value,
                    ),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Plancha frontal',
                  fields: [
                    _buildTextFormField('', (value) => _evaluationModel.planchaFrontal = value),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Lagartija',
                  fields: [
                    _buildTextFormField('', (value) => _evaluationModel.lagartija = value),
                  ],
                ),
                _buildEvaluationCard(
                  title: 'Sentadilla excéntrica',
                  fields: [
                    _buildTextFormField('', (value) => _evaluationModel.sentadillaExcentrica = value),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationCard({
    required String title,
    required List<Widget> fields,
  }) {
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
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideFields(
    String rightLabel,
    String leftLabel,
    Function(String) onSavedRight,
    Function(String) onSavedLeft,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTextFormField(rightLabel, onSavedRight),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: _buildTextFormField(leftLabel, onSavedLeft),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String hint, Function(String) onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
      onSaved: (value) => onSaved(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}