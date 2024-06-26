import 'package:flutter/material.dart';

enum ResultType { error, success, warning, info }

class ResultDialog extends StatelessWidget {
  final String text;
  final ResultType resultType;

  const ResultDialog({super.key, required this.text, required this.resultType});

  @override
  Widget build(BuildContext context) {
    final textColor = _getColorByType(resultType);
    return AlertDialog(
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24.0,
                ),
              )),
            ],
          ),
        ],
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
        return Colors.yellow;
      case ResultType.info:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
