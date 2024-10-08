import 'package:fitsolutions/providers/user_data.dart';
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
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10)),

      child: Row(
        children: [
          if(userData.esBasico() == true) const SizedBox(width: 60),
          if(userData.esBasico() == false) const SizedBox(width: 10), // For the checkbox
          const Expanded(child: Text('', textAlign: TextAlign.center)),
          const Expanded(child: Text('SER', textAlign: TextAlign.center)),
          const Expanded(child: Text('REP', textAlign: TextAlign.center)),
          const Expanded(child: Text('PES', textAlign: TextAlign.center)),
          const SizedBox(width: 25),
          const Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('E')])),
          const Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('P')])),
          if (!userData.esBasico()) ...[
            const Expanded(child: Text('', textAlign: TextAlign.center)),
            const SizedBox(width: 30)
          ]
        ],
      ),
    );
  }
}
