import 'package:fitsolutions/components/CommonComponents/no_data_error.dart';
import 'package:fitsolutions/components/GimnasioComponents/gimnasio_info_user.dart';
import 'package:fitsolutions/modelo/models.dart';
import 'package:fitsolutions/providers/gimnasio_provider.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GimnasioScreenBasico extends StatefulWidget {
  const GimnasioScreenBasico({super.key});

  @override
  State<GimnasioScreenBasico> createState() => _GimnasioScreenBasicoState();
}

class _GimnasioScreenBasicoState extends State<GimnasioScreenBasico> {
  bool showGymForm = false;
  Logger log = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gimnasioProvider = context.read<GimnasioProvider>();
    return  Center(
        child: FutureBuilder<Gimnasio?>(
          future: gimnasioProvider.getInfoSubscripto(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching gym data: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data != null) {
              final gymData = snapshot.data!;
              return GimnasioInfoUser(gimnasio: gymData);
            } else {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NoDataError(
                    message: "No tienes ningun gimnasio/entreandor asociado!",
                  ),
                ],
              );
            }
          },
        ),
      );
  }
}
