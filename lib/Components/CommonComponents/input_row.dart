import 'dart:developer';

import 'package:flutter/material.dart';

class RowInput extends StatefulWidget {
  final List<TextEditingController> comidasController;
  final List<String>? initialComidas;

  const RowInput(
      {super.key, this.initialComidas, required this.comidasController});

  @override
  State<RowInput> createState() => RowInputState();
}

class RowInputState extends State<RowInput> {
  void _addFoodInput() {
    setState(() {
      widget.comidasController.add(TextEditingController());
    });
  }

  void _removeFoodInput() {
    if (widget.comidasController.isNotEmpty) {
      setState(() {
        widget.comidasController.removeLast();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialComidas == null) {
      widget.comidasController.clear();
    } else {
      for (var comida in widget.initialComidas!) {
        widget.comidasController.add(TextEditingController(text: comida));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Wrap(
        spacing: 10.0,
        children: [
          for (int i = 0; i < widget.comidasController.length; i++)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.comidasController[i],
                  ),
                ),
                const SizedBox(width: 10.0),
              ],
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addFoodInput,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: widget.comidasController.length > 1
                    ? _removeFoodInput
                    : null,
                disabledColor:
                    widget.comidasController.length > 1 ? null : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
