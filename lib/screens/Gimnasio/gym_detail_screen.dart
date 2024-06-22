import 'package:fitsolutions/components/GimnasioComponents/gimnasio_clientes.dart';
import 'package:fitsolutions/modelo/Gimnasio.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Inscription/inscription_screen.dart';
import 'package:fitsolutions/screens/Plan/plan_screen.dart';

class GymDetailScreen extends StatelessWidget {
  final Gimnasio gym;

  const GymDetailScreen({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Theme.of(context).cardColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gym.logoUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    gym.logoUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                gym.nombreGimnasio,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    gym.direccion,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (gym.contacto.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone, size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      gym.contacto,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Text(
              'Horarios de apertura:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: gym.horario.entries.map((entry) {
                final day = entry.key;
                final openClose = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${openClose['open']} - ${openClose['close']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 170.0,
                    child: ElevatedButton(
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (context) => GimnasioClientes(
                            gimnasioId: gym.gymId,
                            onClose: () => Navigator.pop(context),
                          ),
                        )
                      },
                      child: const Text('Mis Clientes'),
                    ),
                  ),

            ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(
                        milliseconds: 500), // Adjust the duration as needed
                    pageBuilder: (_, __, ___) => const InscriptionScreen(),
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                )
              },
              child: const Text('Inscripciones'),
            ),
                        ElevatedButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(
                        milliseconds: 500), // Adjust the duration as needed
                    pageBuilder: (_, __, ___) => const PlanScreen(),
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                )
              },
              child: const Text('Rutinas'),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
