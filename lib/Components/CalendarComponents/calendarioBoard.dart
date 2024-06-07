import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/Components/CalendarComponents/calendarioActividadCard.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:flutter/material.dart';

class CalendarioBoard extends StatefulWidget {
  final List<Map<String, dynamic>> calendarios;
  const CalendarioBoard({super.key, required this.calendarios});
  @override
  State<CalendarioBoard> createState() => _CalendarioBoardState();
}

class _CalendarioBoardState extends State<CalendarioBoard> {
  int currentCalendarioIndex = 0;
  List<Map<String, dynamic>>? fetchedActividades = [];

  Future<List<Map<String, dynamic>>> fetchActividades(
      String calendarioId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('actividad')
          .where('calendarioId', isEqualTo: calendarioId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final fetchedActividades =
            querySnapshot.docs.map((doc) => doc.data()).toList();
        return fetchedActividades;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching actividades: $e');
      rethrow;
    }
  }

  void fetchAndDisplayActividades(int index) async {
    final calendarioId = widget.calendarios[index]['calendarioId'];
    fetchedActividades = await fetchActividades(calendarioId);
    setState(() {});
  }

  void changeCalendario(int direction) {
    final newIndex = currentCalendarioIndex + direction;
    if (newIndex >= 0 && newIndex < widget.calendarios.length) {
      currentCalendarioIndex = newIndex;
      fetchAndDisplayActividades(currentCalendarioIndex);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndDisplayActividades(currentCalendarioIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentCalendario = widget.calendarios[currentCalendarioIndex];

    return Column(
      children: [
        Text(
          "Calendario: ${Formatters().extractDate(currentCalendario['diaInicio']) } --- ${Formatters().extractDate(currentCalendario['diaFin'])}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 10),
        Card(
          child: fetchedActividades!.isEmpty
              ? const Center(child: Text('No hay actividades'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fetchedActividades!.length,
                  itemBuilder: (context, index) {
                    final actividad = fetchedActividades![index];
                    return CartaActividad(actividad: actividad);
                  },
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (currentCalendarioIndex > 0)
              ElevatedButton(
                onPressed: () => changeCalendario(-1),
                child: const Icon(Icons.chevron_left),
              ),
            ElevatedButton(
              onPressed: () => changeCalendario(1),
              child: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
