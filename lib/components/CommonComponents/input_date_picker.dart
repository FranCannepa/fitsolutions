import 'package:flutter/material.dart';

class InputDatePicker extends StatefulWidget {
  final String labelText;
  final DateTime? fechaSeleccionada;
  final Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;

  const InputDatePicker(
      {super.key,
      required this.labelText,
      required this.fechaSeleccionada,
      required this.onDateSelected,
      required this.validator});

  @override
  State<InputDatePicker> createState() => _InputDatePickerState();
}

class _InputDatePickerState extends State<InputDatePicker> {
  String selectedDate = "";
  String? validationMessage;

  @override
  void initState() {
    super.initState();
    selectedDate = "";
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
            validator: widget.validator,
      builder: (field) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              SizedBox(
                width: 150,
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
                        validationMessage = widget.validator?.call(pickedDate);
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
                  child:
                      Text(selectedDate.isEmpty ? widget.labelText : selectedDate),
                ),
              ),
              if (validationMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    validationMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}
