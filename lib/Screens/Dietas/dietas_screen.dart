import 'package:fitsolutions/Components/CommonComponents/footer_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class DietasScreen extends StatefulWidget {
  const DietasScreen({super.key});

  @override
  State<DietasScreen> createState() => _DietasScreenState();
}

class _DietasScreenState extends State<DietasScreen> {


  final double targetCalories = 2000;
  final List<String> foodItems = ['Chicken Breast', 'Broccoli', 'Brown Rice'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Objetivo diario de calorías: $targetCalories',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 16.0),
              const Text(
                'Alimentos del día:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  return Text(foodItems[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterBottomNavigationBar(),
    );
  }
}
