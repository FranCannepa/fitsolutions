import 'package:flutter/material.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({
    super.key,
    required this.text,
    this.fontSize = 25.0,
    this.fontFamily = 'Roboto',
    this.icon,
  });

  final String text;
  final double fontSize;
  final String fontFamily;
  final Icon? icon; 

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) icon!, 
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }
}
