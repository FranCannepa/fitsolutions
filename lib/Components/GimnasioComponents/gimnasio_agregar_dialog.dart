import 'package:flutter/material.dart';

class GimnasioAgregar extends StatelessWidget {
  final String propietarioId;
  const GimnasioAgregar({super.key, required this.propietarioId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.black,
        ));
  }
}
