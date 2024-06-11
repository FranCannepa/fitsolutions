import 'package:flutter/material.dart';

enum ResultType { error, success, warning, info }

class ResultDialog extends StatelessWidget {
  final String text;
  final ResultType type;


  const ResultDialog({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    final textColor = _getColorByType(type);

    return AlertDialog(
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        height: 30,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Color _getColorByType(ResultType type) {
    switch (type) {
      case ResultType.error:
        return Colors.red;
      case ResultType.success:
        return Colors.green;
      case ResultType.warning:
        return Colors.orange;
      case ResultType.info:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
