import 'package:fitsolutions/Components/CommonComponents/info_item.dart';
import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/Components/GimnasioComponents/gimnasio_clientes.dart';
import 'package:fitsolutions/Modelo/Gimnasio.dart';
import 'package:fitsolutions/Screens/Plan/plan_screen.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:flutter/material.dart';
import 'package:fitsolutions/screens/Inscription/inscription_screen.dart';

class GimnasioInfo extends StatelessWidget {
  final Gimnasio gimnasio;

  const GimnasioInfo({super.key, required this.gimnasio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenUpperTitle(
          title: "Mi gimnasio",
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTitle(title: gimnasio.nombreGimnasio),
              InfoItem(
                  text: gimnasio.direccion, icon: const Icon(Icons.place)),
              InfoItem(
                  text: gimnasio.contacto as String,
                  icon: const Icon(Icons.call)),
              const SizedBox(width: 25),
              const Row(
                children: [
                   InfoItem(
                    text:  'Horario',
                    icon:   Icon(Icons.access_time),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 170.0,
                    child: ElevatedButton(
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (context) => GimnasioClientes(
                            gimnasioId: gimnasio.gymId,
                            onClose: () => Navigator.pop(context),
                          ),
                        )
                      },
                      child: const Text('Mis Clientes'),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 170.0,
                    child: ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) => const PlanScreen(),
                            transitionsBuilder: (_, Animation<double> animation,
                                __, Widget child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        )
                      },
                      child: const Text('Gestion de Rutinas'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(
                              milliseconds:
                                  500), // Adjust the duration as needed
                          pageBuilder: (_, __, ___) =>
                              const InscriptionScreen(),
                          transitionsBuilder: (_, Animation<double> animation,
                              __, Widget child) {
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
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
