import 'package:fitsolutions/Components/CommonComponents/info_item.dart';
import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/Components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/Components/GimnasioComponents/gimnasio_clientes.dart';
import 'package:fitsolutions/Modelo/Gimnasio.dart';
import 'package:fitsolutions/Screens/Plan/plan_screen.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:flutter/material.dart';

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
                  text: gimnasio.direccion_1, icon: const Icon(Icons.place)),
              InfoItem(
                  text: gimnasio.telefono as String,
                  icon: const Icon(Icons.call)),
              const SizedBox(width: 25),
              InfoItem(
                  text: gimnasio.celular as String,
                  icon: const Icon(Icons.phone_android)),
              Row(
                children: [
                  InfoItem(
                    text: Formatters().to24hs(gimnasio.horarioApertura),
                    icon: const Icon(Icons.access_time),
                  ),
                  InfoItem(
                    text: Formatters().to24hs(gimnasio.horarioClausura),
                  ),
                ],
              ),
              Row(
                children: [
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
                  SizedBox(
                    width: 170.0,
                    child: ElevatedButton(
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (context) => GimnasioClientes(
                            gimnasioId: gimnasio.id,
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
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
