import 'package:fitsolutions/Components/MembresiaComponents/membresiaDetailed.dart';
import 'package:fitsolutions/Modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembershipCard extends StatelessWidget {
  final Membresia membresia;

  const MembershipCard({super.key, required this.membresia});

  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();
    final MembresiaProvider membresiaProvider =
        context.read<MembresiaProvider>();
    return Card(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => MembresiaDetailed(
                membresia: membresia,
                membresiaProvider: membresiaProvider,
                userProvider: userProvider,
                onClose: () => Navigator.pop(context),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  membresia.nombreMembresia,
                  style: const TextStyle(
                      fontSize: 25.0, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  membresia.descripcion ?? 'No hay descripcion',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Costo:"),
                    Text(
                      " \$ ${membresia.costo}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
