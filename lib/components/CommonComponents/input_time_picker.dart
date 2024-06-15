import 'package:flutter/material.dart';

class InputTimePicker extends StatefulWidget {
  final String labelText;
  final TimeOfDay? horaSeleccionada;
  final Function(TimeOfDay) onTimeSelected;

  const InputTimePicker(
      {super.key,
      required this.labelText,
      required this.horaSeleccionada,
      required this.onTimeSelected});

  @override
  State<InputTimePicker> createState() => _InputTimePickerState();
}

class _InputTimePickerState extends State<InputTimePicker> {
  String selectedTime = "";

  @override
  void initState() {
    super.initState();
    selectedTime = "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: OutlinedButton(
        onPressed: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              selectedTime = "${pickedTime.hour}:${pickedTime.minute}";
              widget.onTimeSelected(pickedTime);
            });
          }
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          side: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2.0),
        ),
        child: Text(selectedTime.isEmpty ? widget.labelText : selectedTime),
      ),
    );
  }
}
