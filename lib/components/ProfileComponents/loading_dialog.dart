import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    );
  }
}