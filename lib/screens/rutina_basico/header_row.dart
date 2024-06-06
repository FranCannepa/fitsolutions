import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.grey[300],
      child: const Row(
        children: [
          SizedBox(width: 10), // For the checkbox
          Expanded(child: Text('', textAlign: TextAlign.center)),
          Expanded(child: Text('SER', textAlign: TextAlign.center)),
          Expanded(child: Text('REP', textAlign: TextAlign.center)),
          Expanded(child: Text('PES', textAlign: TextAlign.center)),
          SizedBox(width: 25),
          Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('E')])),
          Expanded(
              child: Row(children: [Icon(Icons.timer, size: 18), Text('P')])),
          Expanded(child: Text('', textAlign: TextAlign.center)),
          Expanded(child: Text('', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
