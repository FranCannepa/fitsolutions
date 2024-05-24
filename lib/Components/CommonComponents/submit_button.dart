import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final Function() onPressed;

  const SubmitButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.orange,
      ),
      onPressed: onPressed,
    );
  }
}
