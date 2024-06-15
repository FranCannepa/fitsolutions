import 'package:fitsolutions/providers/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
  final userData = context.read<UserData>();
    return Container(
      margin: const EdgeInsets.only(top: 16), // Add top margin here
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      color: Theme.of(context).colorScheme.primary,
      child:  Row(
        children: [
          const SizedBox(width: 10), // For the checkbox
          const Expanded(child: Text('', textAlign: TextAlign.center)),
          const Expanded(child: Text('SER', textAlign: TextAlign.center)),
          const Expanded(child: Text('REP', textAlign: TextAlign.center)),
          const Expanded(child: Text('PES', textAlign: TextAlign.center)),
          const SizedBox(width: 25),
          const Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('E')])),
          const Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('P')])),
          if(!userData.esBasico()) ...[
          const Expanded(child: Text('', textAlign: TextAlign.center)),
          const Expanded(child: Text('', textAlign: TextAlign.center)),
          ]
        ],
      ),
    );
  }
}
