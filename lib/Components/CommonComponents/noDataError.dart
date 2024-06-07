import 'package:flutter/material.dart';

class NoDataError extends StatelessWidget {
  final String message; // Parameter to hold the error message

  const NoDataError({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 40.0,
            color: Colors.red,
          ),
          const SizedBox(height: 10.0),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
