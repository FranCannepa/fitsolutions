import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/Utilities/formaters.dart';
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
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: widget.userData['profilePic'] != null &&
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
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        Text(
                          widget.userData['tipo'],
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ScreenSubTitle(text: "Datos"),
        const SizedBox(height: 16.0),
        Container(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Altura: ${widget.userData['altura'] ?? 'No informada'}',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                Text(
                  'Peso: ${widget.userData['peso'] ?? 'No informado'}',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                Text(
                  'Fecha Nacimiento: ${widget.userData['fechaNacimiento'] ?? 'No informada'}',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                Row(
                  children: [
                    Text(
                      'Edad: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      Formatters()
                          .calculateAge(widget.userData['fechaNacimiento'])
                          .toString(),
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ],
                ),
              ],
            ))
      ],
    );
  }
}
