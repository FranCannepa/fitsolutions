import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MembresiaInfo extends StatefulWidget {
  final Map<String, dynamic> membershipData;
  const MembresiaInfo({super.key, required this.membershipData});

  @override
  _MembresiaInfoState createState() => _MembresiaInfoState();
}

class _MembresiaInfoState extends State<MembresiaInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(widget.membershipData['nombreMembresia']),
          const SizedBox(height: 10.0),
          const Text(
            'Gimnasio:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(widget.membershipData['gimnasio']),
          const SizedBox(height: 10.0),
          const Text(
            'Costo:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('${widget.membershipData['costo']} \$'),
          const SizedBox(height: 10.0),
          const Text(
            'Vencimiento:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy')
                .format(widget.membershipData['vencimiento']),
          ),
        ],
      ),
    );
  }
}
