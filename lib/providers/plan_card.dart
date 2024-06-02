import 'package:flutter/material.dart';

import '../modelo/models.dart';

class PlanCard extends StatefulWidget {
  const PlanCard({super.key, this.planRef});

  final Plan? planRef;
  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.48,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.network('https://picsum.photos/250?image=9').image,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.blue,
          width: 1,
        ),
      ),
    );
  }
}
