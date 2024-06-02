import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/screens/Plan/agregar_ejercicio_screen.dart';
import 'package:flutter/material.dart';

class PlanDaysScreen extends StatefulWidget {
  final Plan plan;
  final String week;
  const PlanDaysScreen({super.key, required this.plan, required this.week});

  @override
  State<PlanDaysScreen> createState() => _PlanDaysScreenState();
}

class _PlanDaysScreenState extends State<PlanDaysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividades de la semana'),
          backgroundColor: Colors.amber,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white, // Color of the selected tab's text
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.white,
            indicatorWeight: 15,
            
            // Color of unselected tab's text
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10), // Adjust padding as needed
                  child: const Tab(
                      text: 'D'), // Adjust text and other properties as needed
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'L'), // Adjust text and other properties as needed
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'M'), // Adjust text and other properties as needed
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'M'), // Adjust text and other properties as needed
                ),
              ),
                            Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'J'), // Adjust text and other properties as needed
                ),
              ),
                            Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'V'), // Adjust text and other properties as needed
                ),
              ),
                            Tab(
                child: Container( 
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust border radius as needed
                    color: Colors.blue[200], // Background color of the tab
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 15), // Adjust padding as needed
                  child: const Tab(
                      text: 'S'), // Adjust text and other properties as needed
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Domingo'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Lunes'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Martes'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Miercoles'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Jueves'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Viernes'),
            AgregarEjercicioScreen(
                plan: widget.plan, week: widget.week, dia: 'Sabado'),
          ],
        ),
      ),
    );
  }
}
