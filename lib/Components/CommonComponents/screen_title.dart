import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final Color color;
  final double topSpacing;
  final double bottomSpacing;

  const ScreenTitle({
    super.key,
    required this.title,
    this.fontSize = 30.0,
    this.color = Colors.black,
    this.topSpacing = 30.0,
    this.bottomSpacing = 50.0, 
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing, bottom: bottomSpacing),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
