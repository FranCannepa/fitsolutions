import 'package:fitsolutions/Components/CommonComponents/info_item.dart';
import 'package:fitsolutions/Components/CommonComponents/inputs_screen.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:flutter/material.dart';

class GimnasioInfoUser extends StatelessWidget {
  final Gimnasio gimnasio;

  const GimnasioInfoUser({super.key, required this.gimnasio});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScreenTitle(title: gimnasio.nombreGimnasio),
                    if (gimnasio.logoUrl.isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            gimnasio.logoUrl,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                InfoItem(
                    text: gimnasio.direccion, icon: const Icon(Icons.place)),
                InfoItem(text: gimnasio.contacto, icon: const Icon(Icons.call)),
                const SizedBox(width: 25),
                Text(
                  'Horarios de apertura:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: gimnasio.horario.entries.map((entry) {
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
