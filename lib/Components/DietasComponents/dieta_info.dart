import 'package:fitsolutions/Components/components.dart';
import 'package:fitsolutions/Modelo/Dieta.dart';
import 'package:flutter/material.dart';

class DietaInfo extends StatefulWidget {
  final Dieta dieta;
  const DietaInfo({super.key, required this.dieta});

  @override
  State<DietaInfo> createState() => _DietaInfoState();
}

class _DietaInfoState extends State<DietaInfo> {
  @override
  Widget build(BuildContext context) {
    final dieta = widget.dieta;

    // Sort the comidas list by the day
    final sortedComidas = List.from(dieta.comidas)..sort((a, b) => int.parse(a.dia).compareTo(int.parse(b.dia)));

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: 540,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ScreenTitle(title: dieta.nombre),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/caloriasIcon.png',
                    width: 50.0,
                    height: 50.0,
                  ),
                  const SizedBox(width: 5.0),
                  Text(
                    dieta.caloriasTotales,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              const ScreenSubTitle(text: "Alimentos sugeridos"),
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListView.builder(
                    itemCount: sortedComidas.length,
                    itemBuilder: (context, index) {
                      final comida = sortedComidas[index];
                      return ListTile(
                        title: Text(
                          comida.comida,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Día: ${comida.dia}'),
                            Text('Kcal: ${comida.kcal}'),
                            Text('Tipo de comida: ${comida.meal}'),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_right,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
