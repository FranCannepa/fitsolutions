import 'package:fitsolutions/components/CalendarComponents/calendario_displayer.dart';
import 'package:flutter/material.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.topRight, // Align the button to the bottom right corner
            margin: const EdgeInsets.all(16), // Adjust margin as needed
          ),
          const CalendarioDisplayer(),
        ],
      ),
    );
  }
}
