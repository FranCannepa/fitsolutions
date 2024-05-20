import "package:flutter/material.dart";

class ScreenTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  const ScreenTitle({
    super.key,
    required this.title,
    this.fontSize = 20.0,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}

class MainContainer extends StatelessWidget {
  const MainContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
