import 'package:flutter/material.dart';

class InputDatePicker extends StatefulWidget {
  final String labelText;
  final DateTime? fechaSeleccionada;
  final Function(DateTime) onDateSelected;

  const InputDatePicker({
    super.key,
    required this.labelText,
    required this.fechaSeleccionada,
    required this.onDateSelected
  });

  @override
  State<InputDatePicker> createState() => _InputDatePickerState();
}

class _InputDatePickerState extends State<InputDatePicker> {
  String selectedDate = "";

  @override
  void initState() {
    super.initState();
    selectedDate = "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: OutlinedButton(
        onPressed: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020, 1, 1),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );

          if (pickedDate != null) {
            setState(() {
              selectedDate = "${pickedDate.day}/${pickedDate.month}";
              widget.onDateSelected(pickedDate);
            });
          }
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        child: Text(selectedDate.isEmpty ? widget.labelText : selectedDate),
      ),
    );
  }
}
