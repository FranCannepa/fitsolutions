import 'package:fitsolutions/components/components.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaFormDialog extends StatefulWidget {
  final String origenMembresia;
  final VoidCallback onClose;
  const MembresiaFormDialog(
      {super.key, required this.origenMembresia, required this.onClose});

  @override
  State<MembresiaFormDialog> createState() => _MembresiaFormState();
}

class _MembresiaFormState extends State<MembresiaFormDialog> {
  final _nombreMembresia = TextEditingController();
  final _costoMembresia = TextEditingController();
  final _descripcionMembresia = TextEditingController();
  late Map<String, dynamic> membresiaData = {};
  bool showMembresiaForm = false;

  Map<String, dynamic> collectMembresiaData() {
    return {
      'nombreMembresia': _nombreMembresia.text,
      'costo': _costoMembresia.text,
      'descripcion': _descripcionMembresia.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    final membresiaProvider = context.read<MembresiaProvider>();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScreenSubTitle(text: "Nueva Membresia"),
            const SizedBox(height: 16.0),
            RoundedInputField(
              labelText: 'Nombre',
              controller: _nombreMembresia,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nombre de la membresia';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            RoundedInputField(
              labelText: 'Costo',
              controller: _costoMembresia,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el costo de la membresia';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            RoundedInputField(
              labelText: 'Descripcion',
              controller: _descripcionMembresia,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese una descripcion de la membresia';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            SubmitButton(
                text: "Registrar",
                onPressed: () {
                  final Map<String, dynamic> membresiaData =
                      collectMembresiaData();
                  membresiaProvider.registrarMembresia(membresiaData);
                }),
            TextButton(
              onPressed: widget.onClose,
              child: Text(
                "Cancelar",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
