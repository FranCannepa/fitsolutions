import 'package:flutter/material.dart';

class ScreenSubTitle extends StatelessWidget {
  final String text;
  const ScreenSubTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 20.0,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }
}
