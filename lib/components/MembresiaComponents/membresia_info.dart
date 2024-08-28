import 'package:fitsolutions/Utilities/modal_utils.dart';
import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:fitsolutions/components/CommonComponents/screen_upper_title.dart';
import 'package:fitsolutions/components/MembresiaComponents/membresia_detailed_dialog.dart';
import 'package:fitsolutions/modelo/Membresia.dart';
import 'package:fitsolutions/providers/membresia_provider.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaInfo extends StatefulWidget {
  final Membresia membresia;
  final VoidCallback onChangeMembresia;
  const MembresiaInfo(
      {super.key, required this.membresia, required this.onChangeMembresia});

  @override
  State<MembresiaInfo> createState() => _MembresiaInfoState();
}

class _MembresiaInfoState extends State<MembresiaInfo> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MembresiaProvider>();
    return Column(
      children: [
        const ScreenUpperTitle(title: "Mi Membresia"),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 30.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.membresia.nombreMembresia,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 10),
              Text(
                widget.membresia.descripcion,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      text: '\$',
                    ),
                    TextSpan(
                      text: widget.membresia.costo.toString(),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Wrap(
                verticalDirection: VerticalDirection.down,
                spacing: 8.0,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async => {
                        if (await provider.membresiaActiva() && context.mounted)
                          {
                            ModalUtils.showSuccessModal(
                                context,
                                'Ya tienes una membresia Activa',
                                ResultType.info,
                                () => Navigator.pop(context))
                          }
                        else if (context.mounted)
                          {
                            showDialog(
                              context: context,
                              builder: (context) => MembresiaDetailed(
                                membresia: widget.membresia,
                                membresiaProvider: provider,
                                userProvider: context.read<UserData>(),
                                onClose: () => Navigator.pop(context),
                              ),
                            )
                          }
                      },
                      child: const Text('Pagar Membresia'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async => {
                        if (await provider.membresiaActiva() && context.mounted)
                          {
                            ModalUtils.showSuccessModal(
                                context,
                                'Ya tienes una membresia Activa',
                                ResultType.info,
                                () => Navigator.pop(context))
                          }
                        else
                          {widget.onChangeMembresia()}
                      },
                      child: const Text('Cambiar Membresia'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
