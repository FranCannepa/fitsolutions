import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const LogoWidget({
    super.key,
    required this.assetPath,
    this.width = 100.0,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
    );
  }
}
