import 'package:fitsolutions/Components/DietasComponents/dieta_card.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:flutter/material.dart';

class DietaGestor extends StatefulWidget {
  final List<Dieta?> dietas;
  const DietaGestor({super.key, required this.dietas});

  @override
  State<DietaGestor> createState() => _DietaGestorState();
}

class _DietaGestorState extends State<DietaGestor> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: false, 
              itemCount: widget.dietas.length,
              itemBuilder: (context, index) {
                final dieta = widget.dietas[index] as Dieta;
                return DietaCard(dieta: dieta);
              },
            ),
          ),
          const SizedBox(height: 16.0), 
        ],
      ),
    );
  }
}
