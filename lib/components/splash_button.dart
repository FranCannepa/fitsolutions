import 'package:flutter/material.dart';

class SplashButton extends StatelessWidget {
  const SplashButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(25),
        child: const InkWell(
          child: SizedBox(
            height: 50,
            width: 200,
          ),
        ),
      ),
    );
  }
}