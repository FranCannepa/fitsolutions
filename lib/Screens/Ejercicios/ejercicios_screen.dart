import 'package:fitsolutions/Components/components.dart'; // Assuming ejercicios_card.dart contains EjerciciosCards
import 'package:flutter/material.dart';

class EjerciciosScreen extends StatelessWidget {
  const EjerciciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardData = [
      // {
      //   'title': 'Aeróbicos',
      //   //'imageAssetPath': 'assets/images/exercise_aerobic.jpg',
      //   'cardColor': Colors.lightBlue,
      //   'onTap': () => Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => const CalendarScreen()),
      //       ),
      // },
      {
        'title': 'Flexibilidad',
        //'imageAssetPath': 'assets/images/exercise_flexibility.jpg',
        'cardColor': Colors.lightGreen,
        'onTap': () => Navigator.pushNamed(context, '/ejercicios/flexibilidad'),
      },
      {
        'title': 'Fuerza/Resistencia',
        //'imageAssetPath': 'assets/images/exercise_strength.jpg',
        'cardColor': Colors.orange,
        'onTap': () =>
            Navigator.pushNamed(context, '/ejercicios/fuerza_resistencia'),
      },
    ];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: cardData.length,
            itemBuilder: (context, index) {
              final currentCardData = cardData[index];
              return EjerciciosCards(
                title: currentCardData['title'].toString(),
                cardColor: currentCardData['cardColor'] as Color,
                onTap: currentCardData['onTap'] as Function(),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(),
    );
  }
}
