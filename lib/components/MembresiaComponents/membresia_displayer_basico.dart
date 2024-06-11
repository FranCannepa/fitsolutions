import 'package:fitsolutions/Components/MembresiaComponents/membresiaInfo.dart';
import 'package:fitsolutions/Components/MembresiaComponents/membresia_card.dart';
import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembresiaDisplayerBasico extends StatefulWidget {
  final List<Map<String, dynamic>> membresias;
  const MembresiaDisplayerBasico({super.key, required this.membresias});

  @override
  State<MembresiaDisplayerBasico> createState() =>
      _MembresiaDisplayerBasicoState();
}

class _MembresiaDisplayerBasicoState extends State<MembresiaDisplayerBasico> {
  @override
  Widget build(BuildContext context) {
    final UserData userProvider = context.read<UserData>();

    return Center(
      child: FutureBuilder(
        future: userProvider.getMembresia(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final membresia = snapshot.data!;
            return Visibility(
              visible: true,
              child: MembresiaInfo(membresiaData: membresia),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...widget.membresias.map((membresia) => Center(
                      child: MembershipCard(membership: membresia),
                    )),
              ],
            );
          }
        },
      ),
    );
  }
}
