import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
import 'package:fitsolutions/components/CommonComponents/screenUpperTitle.dart';
import 'package:fitsolutions/providers/notification_service.dart';
import 'package:fitsolutions/screens/Inscription/form_inscription_screen.dart';
import 'package:flutter/material.dart';

class PerfilDetailed extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PerfilDetailed({super.key, required this.userData});

  @override
  State<PerfilDetailed> createState() => _PerfilDetailedState();
}

class _PerfilDetailedState extends State<PerfilDetailed> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenUpperTitle(title: "Perfil"),
        Container(
            width: double.infinity,
            // margin: const EdgeInsets.only(top: 30.0),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                widget.userData['profilePic'] != null &&
                                        widget.userData['profilePic'].isNotEmpty
                                    ? NetworkImage(
                                        widget.userData['profilePic'] as String)
                                    : null,
                            child: widget.userData['profilePic'] == null ||
                                    widget.userData['profilePic'].isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userData['nombreCompleto'] ??
                                    'Usuario de Ejemplo',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              // Text(
                              //   widget.userData['tipo'],
                              //   style: TextStyle(
                              //     fontSize: 20.0,
                              //     color:
                              //         Theme.of(context).colorScheme.secondary,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 25.0,
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              'Altura: ${widget.userData['altura'] ?? 'No informada'}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.scale,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 25.0,
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              'Peso: ${widget.userData['peso'] ?? 'No informado'}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 25.0,
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Text(
                              'Nacimiento: ${widget.userData['fechaNacimiento'] ?? 'No informada'}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 25.0,
                          ),
                          const SizedBox(width: 15.0),
                          Text(
                            'Edad: ',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              Formatters()
                                  .calculateAge(
                                      widget.userData['fechaNacimiento'])
                                  .toString(),
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 500),
                            pageBuilder: (_, __, ___) =>
                                const FormInscriptionScreen(),
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
                      child: const Text('Inscripcion'),
                    ),
                  ],
                )
              ],
            )),
      ],
    );
  }
}
